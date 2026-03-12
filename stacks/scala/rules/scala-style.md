# Scala Style Rules

- Use `scalafmt` for consistent formatting — configure `.scalafmt.conf` in the project root
- Prefer `camelCase` for methods and values, `PascalCase` for types and classes
- Use case classes for data, regular classes for behavior with mutable state
- Avoid `return` statements — the last expression in a block is the return value
- Keep methods short — extract helpers as private methods or local functions
- Use `sealed` on base traits when all subtypes are defined in the same file
- Add ScalaDoc (`/** */`) to public API methods and classes
- Avoid wildcard imports (`import foo._`) in production code — import explicitly
