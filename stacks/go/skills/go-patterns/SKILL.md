# Go Patterns

## Interfaces

Go interfaces are satisfied implicitly -- no `implements` keyword.
Keep interfaces small; the bigger the interface, the weaker the abstraction.

```go
// Good — small, focused interface
type Reader interface {
    Read(p []byte) (n int, err error)
}

// Accept interfaces, return structs
func Process(r io.Reader) (*Result, error) {
    data, err := io.ReadAll(r)
    if err != nil {
        return nil, fmt.Errorf("reading input: %w", err)
    }
    return parse(data)
}

// Define interfaces where they're used, not where they're implemented
// In package "service":
type UserStore interface {
    GetUser(ctx context.Context, id string) (*User, error)
}

// In package "postgres":
type Store struct { db *sql.DB }
func (s *Store) GetUser(ctx context.Context, id string) (*User, error) { ... }
// Satisfies service.UserStore without importing it
```

## Embedding

```go
// Struct embedding — composition over inheritance
type Logger struct {
    prefix string
}
func (l *Logger) Log(msg string) { fmt.Printf("[%s] %s\n", l.prefix, msg) }

type Server struct {
    Logger  // embedded — Server gains Log method
    addr string
}

s := Server{Logger: Logger{prefix: "HTTP"}, addr: ":8080"}
s.Log("starting")  // calls Logger.Log

// Interface embedding — compose interfaces
type ReadWriteCloser interface {
    io.Reader
    io.Writer
    io.Closer
}
```

Embedding is not inheritance. The embedded type's methods receive the embedded
value as their receiver, not the outer struct.

## Error Handling

```go
// Wrap errors with context
func loadConfig(path string) (*Config, error) {
    data, err := os.ReadFile(path)
    if err != nil {
        return nil, fmt.Errorf("loadConfig %s: %w", path, err)
    }
    var cfg Config
    if err := json.Unmarshal(data, &cfg); err != nil {
        return nil, fmt.Errorf("loadConfig parse: %w", err)
    }
    return &cfg, nil
}

// Sentinel errors — package-level, named ErrXxx
var (
    ErrNotFound   = errors.New("not found")
    ErrPermission = errors.New("permission denied")
)

// Check wrapped errors with Is/As
if errors.Is(err, ErrNotFound) {
    http.Error(w, "not found", 404)
    return
}

var pathErr *os.PathError
if errors.As(err, &pathErr) {
    log.Printf("path error on %s: %v", pathErr.Path, pathErr.Err)
}

// Custom error types for rich context
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation: %s — %s", e.Field, e.Message)
}
```

Never use string matching on error messages. Never discard errors with `_`
unless the function's doc comment explicitly says it's safe to ignore.

## Context Propagation

```go
// Always pass context as the first parameter
func FetchUser(ctx context.Context, id string) (*User, error) {
    req, err := http.NewRequestWithContext(ctx, "GET", "/users/"+id, nil)
    if err != nil {
        return nil, err
    }
    resp, err := http.DefaultClient.Do(req)
    // ...
}

// Set timeouts at the call site
ctx, cancel := context.WithTimeout(ctx, 5*time.Second)
defer cancel()
user, err := FetchUser(ctx, "abc123")

// Add values for request-scoped metadata (trace IDs, auth)
type ctxKey string
const requestIDKey ctxKey = "request_id"

func WithRequestID(ctx context.Context, id string) context.Context {
    return context.WithValue(ctx, requestIDKey, id)
}
```

## Concurrency Patterns

### Fan-out / Fan-in

```go
func fanOut(ctx context.Context, urls []string) []string {
    results := make(chan string, len(urls))
    var wg sync.WaitGroup

    for _, url := range urls {
        wg.Add(1)
        go func(u string) {
            defer wg.Done()
            body, err := fetch(ctx, u)
            if err == nil {
                results <- body
            }
        }(url)
    }

    go func() {
        wg.Wait()
        close(results)
    }()

    var out []string
    for r := range results {
        out = append(out, r)
    }
    return out
}
```

### Pipeline

Chain stages with `<-chan` return types: `generate(ctx) -> transform(ctx, in) -> consume(ctx, in)`.
Each stage is a goroutine reading from input channel and writing to output channel.
Always select on `ctx.Done()` in every stage to support cancellation.

### Worker Pool

```go
func workerPool(ctx context.Context, jobs <-chan Job, numWorkers int) <-chan Result {
    results := make(chan Result, numWorkers)
    var wg sync.WaitGroup

    for i := 0; i < numWorkers; i++ {
        wg.Add(1)
        go func() {
            defer wg.Done()
            for job := range jobs {
                select {
                case <-ctx.Done():
                    return
                case results <- process(job):
                }
            }
        }()
    }

    go func() {
        wg.Wait()
        close(results)
    }()
    return results
}
```

### Semaphore

```go
// Limit concurrent goroutines
sem := make(chan struct{}, 10) // max 10 concurrent

for _, item := range items {
    sem <- struct{}{} // acquire
    go func(it Item) {
        defer func() { <-sem }() // release
        process(it)
    }(item)
}
```

### Sync Primitives

```go
// sync.Once — initialize exactly once
var (
    instance *DB
    once     sync.Once
)

func GetDB() *DB {
    once.Do(func() {
        instance = connectDB()
    })
    return instance
}

// sync.Map — concurrent map for append-only or read-heavy workloads
var cache sync.Map
cache.Store("key", value)
if v, ok := cache.Load("key"); ok { ... }

// sync.Pool — reuse temporary objects to reduce GC pressure
var bufPool = sync.Pool{
    New: func() any { return new(bytes.Buffer) },
}
buf := bufPool.Get().(*bytes.Buffer)
buf.Reset()
defer bufPool.Put(buf)
```

## Performance

### Escape Analysis

```go
// This allocation escapes to heap — pointer returned
func newUser(name string) *User {
    u := User{Name: name}  // allocated on heap
    return &u
}

// This stays on the stack — no pointer escapes
func processUser(name string) string {
    u := User{Name: name}  // stays on stack
    return u.Name
}

// Check with: go build -gcflags="-m" ./...
```

### Memory Alignment

```go
// Bad — padding wastes 7 bytes per struct
type Bad struct {
    a bool    // 1 byte
    b int64   // 8 bytes (7 bytes padding before b)
    c bool    // 1 byte (7 bytes padding after c)
}  // 24 bytes total

// Good — fields ordered by size, descending
type Good struct {
    b int64   // 8 bytes
    a bool    // 1 byte
    c bool    // 1 byte
}  // 16 bytes total
```

### Profiling

```go
import _ "net/http/pprof"

// In main:
go func() { log.Println(http.ListenAndServe(":6060", nil)) }()

// Then:
// go tool pprof http://localhost:6060/debug/pprof/heap
// go tool pprof http://localhost:6060/debug/pprof/profile?seconds=30
```

### Benchmarks

```go
func BenchmarkParse(b *testing.B) {
    data := loadTestData()
    b.ResetTimer()
    for i := 0; i < b.N; i++ {
        Parse(data)
    }
}

// Run: go test -bench=BenchmarkParse -benchmem ./...
// Output: BenchmarkParse-8  50000  23456 ns/op  4096 B/op  12 allocs/op
```

## Common Pitfalls

- **Goroutine leak**: Always provide a shutdown path. Use `ctx.Done()` or close
  the input channel. Check with `runtime.NumGoroutine()` in tests.
- **Loop variable capture**: In Go < 1.22, `go func() { use(v) }()` inside a
  `for _, v := range` captures the loop variable by reference. Use a parameter
  or upgrade to Go 1.22+ which scopes the variable per iteration.
- **Nil interface vs nil pointer**: An interface holding a nil pointer is not nil.
  `var p *MyStruct = nil; var i interface{} = p; i != nil` is `true`.
- **Slice append gotcha**: `append` may return a new backing array. Never assume
  two slices share memory after `append`.
- **defer in loops**: `defer` runs at function exit, not loop iteration.
  Use an anonymous function inside the loop if you need per-iteration cleanup.
- **Race conditions**: Always run tests with `-race`. Data races are undefined
  behavior in Go — they can cause memory corruption.

```go
// Bug — defer closes only the last file
for _, f := range files {
    file, _ := os.Open(f)
    defer file.Close()  // all deferred to function end
}

// Fix — wrap in closure
for _, f := range files {
    func() {
        file, _ := os.Open(f)
        defer file.Close()
        process(file)
    }()
}
```
