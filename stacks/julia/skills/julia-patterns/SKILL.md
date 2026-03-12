# Julia Patterns

## Type System
- Use multiple dispatch — define methods for specific type combinations instead of branching
- Use abstract types to define interfaces: `abstract type Shape end`
- Use parametric types for generic containers: `struct Point{T<:Number} x::T; y::T end`
- Prefer concrete field types in structs for performance — avoid `Any`
- Use `Union{Nothing, T}` for optional values

## Performance
- Write type-stable functions — the return type should be inferrable from argument types
- Avoid global variables in hot paths — pass data as function arguments or use `const`
- Use `@views` for array slicing to avoid copies
- Profile with `@time` and `@allocated` — reduce allocations in inner loops
- Use `StaticArrays.jl` for small fixed-size arrays

## Functional Style
- Use broadcasting with `.` for element-wise operations: `f.(array)`
- Leverage comprehensions: `[x^2 for x in 1:10 if iseven(x)]`
- Use `map`, `filter`, `reduce` for functional transformations
- Use `do` blocks for anonymous functions passed to higher-order functions
- Compose functions with `∘`: `(f ∘ g)(x)` is `f(g(x))`

## Project Structure
- Use `Pkg.generate("MyPackage")` to scaffold new packages
- Organize code in `src/` with a main module file and included subfiles
- Use `Project.toml` and `Manifest.toml` for reproducible environments
- Place tests in `test/runtests.jl` — use `@testset` and `@test`

## Metaprogramming
- Use macros sparingly — prefer functions unless compile-time code generation is needed
- Use `@generated` functions for type-specialized code generation
- Leverage built-in macros: `@assert`, `@show`, `@debug`, `@time`
- Use `Base.@kwdef` for structs with keyword constructors and defaults
