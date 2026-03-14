# Julia Patterns

## Multiple Dispatch

Define methods for specific type combinations instead of branching on types.

```julia
abstract type Shape end
struct Circle <: Shape
    radius::Float64
end
struct Rectangle <: Shape
    width::Float64
    height::Float64
end

# Methods dispatch on argument types
area(c::Circle) = π * c.radius^2
area(r::Rectangle) = r.width * r.height

# Multi-argument dispatch
collides(a::Circle, b::Circle) = norm(a.center - b.center) < a.radius + b.radius
collides(a::Circle, b::Rectangle) = circle_rect_collision(a, b)
collides(a::Rectangle, b::Circle) = collides(b, a)  # reuse
```

## Type System and Parametric Types

```julia
# Parametric struct — concrete field types for performance
struct Point{T<:Number}
    x::T
    y::T
end

# Type alias for optional values
const Maybe{T} = Union{Nothing, T}

# Inner constructors for validation
struct PositiveInt
    value::Int
    function PositiveInt(v)
        v > 0 || throw(ArgumentError("Must be positive, got $v"))
        new(v)
    end
end

# Keyword constructor with defaults
Base.@kwdef struct Config
    host::String = "localhost"
    port::Int = 8080
    timeout::Float64 = 30.0
end

cfg = Config(port=3000)
```

## Metaprogramming and Macros

```julia
# Expressions are first-class
ex = :(x + 1)
eval(ex)

# Macro: code transformation at compile time
macro assert_positive(expr)
    quote
        val = $(esc(expr))
        val > 0 || error("Expected positive value, got $val")
        val
    end
end

# Usage: @assert_positive compute_value()

# Generated functions — type-specialized code
@generated function dot_product(a::NTuple{N,T}, b::NTuple{N,T}) where {N,T}
    exprs = [:(a[$i] * b[$i]) for i in 1:N]
    :(+($(exprs...)))
end
```

## Broadcasting

```julia
# Element-wise operations with dot syntax
xs = [1.0, 2.0, 3.0, 4.0]
ys = sin.(xs)           # broadcast sin over array
zs = xs .^ 2 .+ 1      # fused broadcast: no temporaries

# Custom functions broadcast automatically
normalize(x, lo, hi) = (x - lo) / (hi - lo)
normalized = normalize.(data, 0.0, 100.0)

# @. macro: dot every call and operator in the expression
@. result = sin(xs) + cos(ys) * 2  # equivalent to: sin.(xs) .+ cos.(ys) .* 2
```

## Performance: Type Stability

```julia
# BAD: type-unstable — return type depends on runtime value
function bad_lookup(d, key)
    haskey(d, key) ? d[key] : "missing"  # might return Int or String
end

# GOOD: type-stable
function good_lookup(d::Dict{K,V}, key::K)::Union{V, Nothing} where {K,V}
    get(d, key, nothing)
end

# Check type stability with @code_warntype
@code_warntype good_lookup(Dict("a" => 1), "a")
```

## Performance: Allocation Avoidance

```julia
# Use @views to avoid array copies
function process_columns!(matrix)
    for col in eachcol(matrix)
        col .= col ./ sum(col)  # in-place normalization
    end
end

# Pre-allocate output arrays
function moving_average!(out::Vector{Float64}, data::Vector{Float64}, window::Int)
    @inbounds for i in window:length(data)
        s = 0.0
        for j in 0:(window-1)
            s += data[i-j]
        end
        out[i] = s / window
    end
    out
end

# Use StaticArrays for small fixed-size data
using StaticArrays
v = SVector(1.0, 2.0, 3.0)  # stack-allocated, no GC pressure
```

## SIMD and Performance Annotations

```julia
# @simd for auto-vectorization
function dot_simd(a::Vector{Float64}, b::Vector{Float64})
    s = 0.0
    @inbounds @simd for i in eachindex(a)
        s += a[i] * b[i]
    end
    s
end

# Use @time and @allocated to measure
@time result = heavy_computation()
@allocated single_iteration()  # should be 0 in hot loops

# Profile with Profile stdlib
using Profile
@profile heavy_computation()
Profile.print(format=:flat, sortedby=:count)
```

## Package Development

```julia
# Standard package layout:
# MyPkg/
#   Project.toml
#   src/MyPkg.jl
#   test/runtests.jl

# src/MyPkg.jl
module MyPkg
export greet, Config

include("config.jl")
include("core.jl")

end # module
```

## Testing

```julia
using Test

@testset "Circle" begin
    c = Circle(2.0)
    @test area(c) ≈ 4π
    @test area(c) > 0
end

@testset "Config defaults" begin
    cfg = Config()
    @test cfg.host == "localhost"
    @test cfg.port == 8080
end

@testset "Errors" begin
    @test_throws ArgumentError PositiveInt(-1)
    @test_throws ArgumentError PositiveInt(0)
end

# Property-based testing with PropCheck.jl
using PropCheck
@testset "area always positive" begin
    @check r -> area(Circle(abs(r) + 0.01)) > 0
end
```
