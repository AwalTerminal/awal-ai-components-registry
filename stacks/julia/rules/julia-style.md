# Julia Style Rules

## Formatting
- Use `JuliaFormatter.jl` for consistent formatting — run before every commit
- 4-space indentation (Julia convention)
- Keep lines under 92 characters
- One blank line between top-level definitions

## Naming
- Functions and variables: `snake_case` (`calculate_area`, `user_id`)
- Types and modules: `PascalCase` (`HttpClient`, `OrderService`)
- Constants: `UPPER_SNAKE_CASE` or `PascalCase` depending on context
- Mutating functions: end with `!` (`sort!`, `push!`, `normalize!`)
- Type parameters: single uppercase letters (`T`, `N`) or descriptive (`K`, `V`)

## Types
- Add type annotations to all struct fields — never leave as `Any`
- Prefer immutable `struct` over `mutable struct` unless mutation is required
- Use parametric types for generic containers: `struct Pair{T} ... end`
- Use abstract types to define method interfaces: `abstract type Shape end`
- Use `Union{Nothing, T}` for optional values, not sentinel values

## Functions
- Write type-stable functions — return type should be inferrable from argument types
- Use `!` suffix for mutating functions: `sort!` vs `sort`
- Prefer explicit argument types in public APIs for clarity and dispatch
- Keep functions under 40 lines — extract inner logic into helper functions
- Use keyword arguments for optional configuration: `f(x; tol=1e-6)`

## Performance
- Avoid global variables in hot paths — pass as function arguments or use `const`
- Use `@views` for array slicing to avoid copies
- Avoid containers with `Any` element type — use concrete types
- Use `@inbounds` only after verifying bounds are correct
- Profile before optimizing — use `@time`, `@allocated`, `@code_warntype`

## Imports
- Use `using` for packages: `using LinearAlgebra`
- Use `import` when extending specific methods: `import Base: show, length`
- Prefer explicit imports for clarity: `using Statistics: mean, std`

## Documentation
- Write docstrings (`"""..."""`) for all exported functions and types
- Include argument descriptions, return types, and usage examples in docstrings
- Use `@doc` for adding documentation to constants and macros

## Testing
- Place tests in `test/runtests.jl` with `@testset` and `@test`
- Use `@test_throws` for expected exceptions
- Use approximate comparison with `@test x ≈ y` for floating-point
- Run `Pkg.test()` before committing
