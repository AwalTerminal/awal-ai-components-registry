# Dart Style Rules

- Run `dart format` before committing — enforce with CI
- Use `lowerCamelCase` for variables and functions, `UpperCamelCase` for classes and types
- Enable and fix all `dart analyze` warnings — use `analysis_options.yaml` for custom rules
- Prefer `final` over `var` for local variables that aren't reassigned
- Use null-aware operators (`?.`, `??`, `??=`) instead of manual null checks
- Keep classes focused — use mixins for shared behavior across unrelated types
- Write `///` doc comments for all public API members
- Prefer `const` constructors for immutable classes — enables compile-time constants
