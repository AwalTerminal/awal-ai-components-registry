# Rust Patterns

## Error Handling
- Use `Result<T, E>` for recoverable errors, `panic!` only for bugs
- Use `thiserror` for library error types, `anyhow` for application errors
- Use `?` operator for error propagation — keep functions clean
- Implement `Display` and `Error` for custom error types

## Ownership & Borrowing
- Prefer borrowing (`&T`) over ownership when the function doesn't need to own the data
- Use `&str` in function parameters, not `String`
- Use `Cow<'_, str>` when you might or might not need to allocate
- Clone only when you've proven it's needed — don't clone to silence the borrow checker

## Concurrency
- Use `Arc<Mutex<T>>` for shared mutable state between threads
- Prefer channels (`mpsc`, `crossbeam`) for communication over shared state
- Use `tokio` for async I/O, `rayon` for CPU-bound parallelism
- Use `Send + Sync` bounds explicitly when designing concurrent APIs

## Performance
- Use iterators and iterator adaptors — they optimize well
- Prefer `Vec` over `LinkedList` in almost all cases
- Use `#[inline]` sparingly — let the compiler decide
- Profile before optimizing: `cargo flamegraph`, `criterion` for benchmarks

## Project Structure
- Use workspaces for multi-crate projects
- Keep `lib.rs` as the public API surface
- Use `mod.rs` or inline modules for organization
- Feature-flag optional dependencies with `[features]` in `Cargo.toml`
