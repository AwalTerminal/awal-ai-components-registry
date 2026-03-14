# Go Commands

## Build

- `go build ./...` -- build all packages
- `go build -o bin/app ./cmd/app` -- build specific binary to output path
- `go build -race ./...` -- build with race detector
- `go build -ldflags="-s -w"` -- strip debug info for smaller binary
- `CGO_ENABLED=0 go build` -- static binary without cgo

## Test

- `go test ./...` -- all packages
- `go test -v ./...` -- verbose output
- `go test -race ./...` -- with race detector (always use in CI)
- `go test -cover ./...` -- with coverage summary
- `go test -coverprofile=coverage.out ./...` -- generate coverage file
- `go tool cover -html=coverage.out` -- open HTML coverage report
- `go test -run TestName ./pkg/` -- specific test
- `go test -count=1 ./...` -- disable test caching
- `go test -bench=. -benchmem ./...` -- run benchmarks with alloc stats
- `go test -short ./...` -- skip long-running tests (check `testing.Short()`)

## Lint

- `golangci-lint run` -- run all configured linters
- `go vet ./...` -- built-in static analysis
- `staticcheck ./...` -- advanced static analysis

## Format

- `gofmt -w .` -- format all files
- `goimports -w .` -- format and fix imports

## Module Management

- `go mod init module/path` -- initialize module
- `go mod tidy` -- add missing / remove unused deps
- `go mod download` -- download deps to cache
- `go mod vendor` -- vendor all dependencies
- `go get package@version` -- add or update a dependency

## Profiling

- `go test -cpuprofile=cpu.out -bench=. ./...` -- CPU profile from benchmarks
- `go tool pprof cpu.out` -- analyze CPU profile
- `go tool pprof -http=:8080 cpu.out` -- browser-based flame graph

## Generate

- `go generate ./...` -- run go:generate directives
