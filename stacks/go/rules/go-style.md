# Go Style Rules

## Naming

- Packages: short, lowercase, single-word (`http`, `user`, `auth`); no `_` or camelCase
- Exported names: `UpperCamelCase` (`NewServer`, `ErrNotFound`)
- Unexported names: `lowerCamelCase` (`parseHeader`, `connPool`)
- Acronyms: all caps when exported (`HTTPClient`, `XMLParser`); lowercase when not (`httpClient`)
- Interfaces: single-method interfaces named by method + "er" (`Reader`, `Stringer`, `Closer`)
- Getters: `Name()` not `GetName()`; setters: `SetName()`
- Errors: `ErrXxx` for sentinel errors, `XxxError` for error types
- Test helpers: unexported, start with `setup` or `new` (`setupTestDB`, `newTestServer`)

## File Structure

- `main.go` -- minimal entry point, delegates to packages
- `internal/` -- packages that cannot be imported outside the module
- `pkg/` -- optional; shared library code (many projects skip this)
- Group files by domain: `user/store.go`, `user/handler.go`, `user/service.go`
- Test files: `foo_test.go` alongside `foo.go` in the same package
- External test packages: `package foo_test` for black-box tests of public API

## Module Organization

- One `go.mod` per project (mono-module); multi-module only for independent versioning
- Use `internal/` aggressively to keep public API surface small
- Group imports in three blocks: stdlib, external, internal (enforced by `goimports`)
- Avoid circular dependencies; refactor shared types into a separate package

## Error Handling Conventions

- Always handle errors; never use `_` for error returns
- Wrap with context: `fmt.Errorf("operation: %w", err)`
- Use sentinel errors for expected conditions; custom types for rich context
- Return errors, don't log and return — let the caller decide
- Only log errors at the top of the call stack (main, HTTP handler, etc.)

## Concurrency Conventions

- Every goroutine must have a clear owner and shutdown mechanism
- Pass `context.Context` as the first argument to all functions that may block
- Use `errgroup.Group` for structured concurrent work with error propagation
- Protect shared state with `sync.Mutex`; prefer channels for communication
- Never share memory by communicating; communicate by sharing channels

## Testing Conventions

- Table-driven tests with `t.Run()` subtests for named cases
- Use `testify/assert` or `testify/require` for readable assertions
- Use `httptest.NewServer` for integration tests against HTTP handlers
- Use `t.Parallel()` for tests that can run concurrently
- Test files in the same package for unit tests; `_test` package for API tests
- Use `testdata/` directory for test fixtures (automatically ignored by `go build`)
- Benchmarks in `_test.go` files; name `BenchmarkXxx`

## Documentation

- All exported names must have a doc comment starting with the name
- Package comment on `doc.go` or at the top of the primary file
- Use `// Deprecated:` comment to mark deprecated symbols
- Examples in `_test.go` with `func ExampleXxx()` are rendered in godoc

## Formatting

- `gofmt` / `goimports` — non-negotiable; enforced by editor and CI
- No configuration — Go has one formatting standard
- Use `golangci-lint` with a `.golangci.yml` config for comprehensive linting
- Recommended linters: `errcheck`, `govet`, `staticcheck`, `gosec`, `revive`

## Code Style

- Keep functions short — if a function is more than 30 lines, consider extracting
- Prefer early returns over deep nesting
- Use named return values only when they clarify the function signature
- Avoid `init()` functions — they make testing and reasoning harder
- Prefer `var x Type` over `x := Type{}` for zero-value initialization
- Use constants for magic numbers and string literals
