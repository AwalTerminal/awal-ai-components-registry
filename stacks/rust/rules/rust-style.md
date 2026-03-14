# Rust Style Rules

## Naming

- Types, traits, enum variants: `UpperCamelCase` (`HashMap`, `Display`, `Some`)
- Functions, methods, variables, modules: `snake_case` (`read_file`, `is_empty`)
- Constants and statics: `SCREAMING_SNAKE_CASE` (`MAX_RETRIES`, `DEFAULT_PORT`)
- Lifetimes: short lowercase (`'a`, `'de`); descriptive when multiple (`'input`, `'output`)
- Crate names: `kebab-case` in Cargo.toml, `snake_case` in code (`my-crate` becomes `my_crate`)
- Type parameters: single uppercase letter (`T`, `E`, `K`, `V`) or descriptive (`Item`, `Error`)

## File Structure

- `src/lib.rs` — public API root for libraries
- `src/main.rs` — entry point for binaries; keep minimal, delegate to lib
- `src/bin/` — additional binary targets
- Modules: one file per module (`foo.rs`) or directory (`foo/mod.rs` or `foo.rs` + `foo/`)
- Tests: inline `#[cfg(test)] mod tests` for unit tests; `tests/` directory for integration tests
- Benchmarks: `benches/` directory with criterion

## Module Organization

- Re-export important types at the crate root for flat import paths
- Use `pub(crate)` for crate-internal items; avoid `pub` for implementation details
- Group related types and functions into modules by domain
- Use `prelude` module pattern for commonly-used re-exports

## Formatting and Linting

- Run `cargo fmt` before every commit — non-negotiable
- Run `cargo clippy` and fix all warnings; use `#[allow(...)]` only with a comment explaining why
- Use `rustfmt.toml` for project-wide formatting preferences
- Enable `clippy::pedantic` in CI; selectively allow noisy lints

## Error Handling Conventions

- Libraries: define typed errors with `thiserror`; implement `Error + Display + Debug`
- Applications: use `anyhow::Result` with `.context()` for human-readable chains
- Never panic in library code; use `Result` for all fallible operations
- Use `#[must_use]` on `Result`-returning functions and builder methods

## Documentation

- All `pub` items must have `///` doc comments
- Include examples in doc comments — they run as tests (`cargo test --doc`)
- Use `//!` for module-level documentation at the top of the file
- Link to related types with `[`TypeName`]` in doc comments

## Dependencies

- Pin major versions in `Cargo.toml`: `serde = "1"` not `serde = "*"`
- Use `[workspace.dependencies]` for version consistency across workspace members
- Feature-gate optional heavy dependencies: `[features] default = []`
- Audit deps with `cargo audit`; minimize transitive dependency count

## Testing Conventions

- Unit tests in `#[cfg(test)] mod tests` at the bottom of the source file
- Integration tests in `tests/` — each file is a separate test binary
- Name tests descriptively: `fn parse_empty_input_returns_error()`
- Use `#[should_panic(expected = "...")]` for panic tests
- Use `proptest` or `quickcheck` for property-based tests on core logic

## Unsafe Code

- Avoid `unsafe` unless absolutely necessary; prefer safe abstractions
- Every `unsafe` block must have a `// SAFETY:` comment
- Encapsulate `unsafe` in small safe-API modules; never expose raw unsafe to callers
- Use `#[deny(unsafe_op_in_unsafe_fn)]` to require safety comments inside unsafe fns

## Performance Conventions

- Accept `&str` not `String`, `&[T]` not `Vec<T>` in function parameters
- Return concrete types or `impl Trait`; avoid `Box<dyn Trait>` unless needed
- Use `#[inline]` only after profiling — the compiler usually inlines correctly
- Prefer iterators over index loops; they optimize better and prevent bounds checks
