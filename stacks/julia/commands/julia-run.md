# Julia Run & Test

Run with julia CLI:
- `julia script.jl` — run a script
- `julia --project=. -e "using Pkg; Pkg.test()"` — run all tests
- `julia --project=.` — start a REPL with project environment active
- `julia -e "using JuliaFormatter; format(\".\")"` — format all source files
- `julia --project=. -e "using Pkg; Pkg.instantiate()"` — install dependencies
- `julia --project=. -e "using Pkg; Pkg.update()"` — update dependencies
- `julia -t auto script.jl` — run with all available threads
