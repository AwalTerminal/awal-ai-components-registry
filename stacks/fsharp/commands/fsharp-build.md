# F# Build & Test Commands

## dotnet CLI

- `dotnet build` — compile the project
- `dotnet build -c Release` — compile in release mode
- `dotnet run` — build and run the default project
- `dotnet run --project src/MyApp` — run a specific project
- `dotnet test` — run all tests
- `dotnet test --filter "FullyQualifiedName~Validation"` — run tests matching a pattern
- `dotnet watch test` — re-run tests on file changes
- `dotnet watch run` — re-run app on file changes
- `dotnet publish -c Release -r osx-arm64 --self-contained` — publish self-contained binary
- `dotnet fsi script.fsx` — run an F# script

## Formatting

- `fantomas --check .` — check formatting without modifying
- `fantomas .` — auto-format all F# files
- `dotnet format` — format using .editorconfig rules

## Package Management

- `dotnet add package FSharp.Data` — add a NuGet package
- `dotnet restore` — restore all dependencies
- `dotnet list package` — list installed packages
- `dotnet list package --outdated` — check for outdated packages
- `paket install` — install dependencies (if using Paket)

## Testing Frameworks

- `dotnet test --logger "console;verbosity=detailed"` — verbose test output
- `dotnet test --collect:"XPlat Code Coverage"` — collect coverage data
- `dotnet run --project tests/MyTests -- --summary` — Expecto with summary
- `dotnet run --project tests/MyTests -- --filter "validation"` — Expecto filtered

## Project Scaffolding

- `dotnet new console -lang F# -o MyApp` — new console app
- `dotnet new classlib -lang F# -o MyLib` — new class library
- `dotnet new sln` — new solution file
- `dotnet sln add src/MyApp/MyApp.fsproj` — add project to solution

## REPL

- `dotnet fsi` — start F# Interactive
- `#r "nuget: FSharp.Data"` — reference a NuGet package in FSI
- `#load "MyModule.fs"` — load a source file in FSI
