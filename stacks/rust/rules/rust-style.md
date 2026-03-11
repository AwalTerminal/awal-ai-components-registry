# Rust Style Rules

- Run `cargo clippy` before committing — fix all warnings
- Use `cargo fmt` for consistent formatting
- Prefer `&str` over `String` in function parameters
- Use `impl Trait` in argument position for flexibility
- Return concrete types, not `Box<dyn Trait>`, unless needed for object safety
- Use `#[must_use]` on functions where ignoring the return value is likely a bug
- Document public items with `///` doc comments
- Use `todo!()` as a placeholder — never ship it
