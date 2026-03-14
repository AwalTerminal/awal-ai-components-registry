# Rust Commands

## Build

- `cargo build` -- debug build
- `cargo build --release` -- optimized release build
- `cargo build --target aarch64-apple-darwin` -- cross-compile to specific target

## Test

- `cargo test` -- run all tests (unit + integration + doc tests)
- `cargo test test_name` -- run tests matching a name
- `cargo test --lib` -- unit tests only
- `cargo test --doc` -- doc tests only
- `cargo test -- --nocapture` -- show println output

## Coverage

- `cargo llvm-cov` -- line coverage (requires cargo-llvm-cov)
- `cargo llvm-cov --html` -- HTML coverage report
- `cargo tarpaulin` -- alternative coverage tool

## Lint

- `cargo clippy` -- run lints
- `cargo clippy -- -W clippy::pedantic` -- stricter lints
- `cargo clippy --fix` -- auto-fix lint warnings

## Format

- `cargo fmt` -- format all source files
- `cargo fmt -- --check` -- check formatting without modifying

## Benchmarks

- `cargo bench` -- run all benchmarks
- `cargo bench --bench bench_name` -- run specific benchmark file

## Dependencies

- `cargo add serde --features derive` -- add a dependency
- `cargo update` -- update deps to latest allowed versions
- `cargo audit` -- check for known vulnerabilities
- `cargo tree` -- show dependency tree
- `cargo tree -d` -- show duplicate dependencies

## Documentation

- `cargo doc --open` -- build and open docs
- `cargo doc --no-deps` -- docs for your crate only

## Diagnostics

- `cargo check` -- type-check without codegen (faster than build)
- `cargo expand` -- show macro-expanded code (requires cargo-expand)
- `cargo flamegraph` -- generate flamegraph (requires cargo-flamegraph)
- `RUSTFLAGS="-Z sanitizer=address" cargo test` -- run with ASan (nightly)
