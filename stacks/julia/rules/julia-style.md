# Julia Style Rules

- Use `JuliaFormatter.jl` for consistent formatting
- Use `snake_case` for functions and variables, `PascalCase` for types and modules
- Add type annotations to struct fields — never leave them as `Any`
- Write docstrings (`"""..."""`) for all exported functions
- Prefer immutable `struct` over `mutable struct` unless mutation is required
- Use `using` for packages, `import` only when extending specific methods
- Keep functions type-stable — avoid containers with `Any` element type in hot paths
- Run tests with `Pkg.test()` before committing
