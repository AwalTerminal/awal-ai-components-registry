# Go Patterns

## Error Handling
- Always check errors; never use `_` to discard them
- Wrap errors with context: `fmt.Errorf("failed to parse config: %w", err)`
- Use `errors.Is()` and `errors.As()` for error comparison, not string matching
- Define sentinel errors as package-level variables: `var ErrNotFound = errors.New("not found")`

## Concurrency
- Use goroutines for independent tasks, channels for communication
- Always use `context.Context` for cancellation and timeouts
- Prefer `sync.WaitGroup` for fan-out/fan-in patterns
- Use `sync.Mutex` only when channels are impractical
- Never start a goroutine without a clear shutdown path

## Project Structure
- Follow standard Go project layout
- Keep `main.go` minimal — delegate to internal packages
- Use `internal/` to prevent external imports
- Group by domain, not by layer (avoid `models/`, `controllers/`)

## Style
- Use `gofmt` / `goimports` formatting
- Exported names should have doc comments
- Keep functions short — extract when complexity grows
- Prefer returning structs over using pointer receivers for constructors
- Use table-driven tests with `t.Run()` subtests
