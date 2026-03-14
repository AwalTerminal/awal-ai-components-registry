# Julia Run & Test Commands

## Running

- `julia script.jl` — run a script
- `julia --project=. script.jl` — run with project environment
- `julia --project=.` — start REPL with project environment
- `julia -t auto script.jl` — run with all available threads
- `julia -O3 script.jl` — run with aggressive optimization
- `julia -e 'println("hello")'` — evaluate expression

## Package Management (Pkg)

- `julia --project=. -e "using Pkg; Pkg.instantiate()"` — install dependencies from Manifest
- `julia --project=. -e "using Pkg; Pkg.add(\"PackageName\")"` — add a dependency
- `julia --project=. -e "using Pkg; Pkg.update()"` — update all dependencies
- `julia --project=. -e "using Pkg; Pkg.rm(\"PackageName\")"` — remove a dependency
- `julia --project=. -e "using Pkg; Pkg.status()"` — list installed packages
- `julia -e "using Pkg; Pkg.generate(\"MyPackage\")"` — scaffold a new package

## Testing

- `julia --project=. -e "using Pkg; Pkg.test()"` — run all tests
- `julia --project=. test/runtests.jl` — run tests directly
- `julia --project=. -e "using Pkg; Pkg.test(; test_args=[\"--filter=pattern\"])"` — filtered tests

## Formatting and Linting

- `julia -e "using JuliaFormatter; format(\".\")"` — format all source files
- `julia -e "using JuliaFormatter; format(\"src/module.jl\")"` — format a single file
- `julia -e "using JET; @report_opt f(args...)"` — static analysis with JET.jl
- `julia -e "using Aqua; Aqua.test_all(MyPackage)"` — package quality checks

## Profiling and Debugging

- `julia -e "using Profile; @profile f(); Profile.print(format=:flat)"` — CPU profiling
- `julia --track-allocation=user script.jl` — track memory allocations
- `julia -e "@time f()"` — basic timing and allocation measurement
- `julia -e "@code_warntype f(x)"` — check type stability
- `julia -e "@code_native f(x)"` — view generated machine code
- `julia -e "@code_llvm f(x)"` — view LLVM IR

## Compilation

- `julia -e "using PackageCompiler; create_sysimage(:MyPkg; sysimage_path=\"sys.so\")"` — create custom sysimage
- `julia -e "using PackageCompiler; create_app(\".\", \"build\")"` — compile standalone app

## Documentation

- `julia --project=docs -e "using Documenter; include(\"docs/make.jl\")"` — build docs
