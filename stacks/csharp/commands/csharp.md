# C# / .NET Commands

## Project Management
- `dotnet new webapi -n ProjectName` — create a new Web API project
- `dotnet new classlib -n LibName` — create a class library
- `dotnet new sln -n SolutionName` — create a solution
- `dotnet sln add src/Project/Project.csproj` — add project to solution
- `dotnet add package Newtonsoft.Json` — add NuGet package
- `dotnet restore` — restore all NuGet packages

## Build
- `dotnet build` — build the solution/project
- `dotnet build -c Release` — build in Release configuration
- `dotnet publish -c Release -o ./publish` — publish for deployment
- `dotnet run` — build and run the project
- `dotnet watch run` — run with hot reload

## Testing
- `dotnet test` — run all tests
- `dotnet test --filter "FullyQualifiedName~OrderService"` — filter by name
- `dotnet test --filter "Category=Integration"` — filter by trait/category
- `dotnet test --collect:"XPlat Code Coverage"` — collect coverage data
- `dotnet test --logger "console;verbosity=detailed"` — verbose output

## Code Quality
- `dotnet format` — auto-format code
- `dotnet format --verify-no-changes` — check formatting (CI)
- `dotnet format analyzers` — run analyzer fixes

## Entity Framework
- `dotnet ef migrations add MigrationName` — create a migration
- `dotnet ef database update` — apply pending migrations
- `dotnet ef migrations list` — list all migrations
- `dotnet ef database drop` — drop the database

## Tools
- `dotnet tool install -g dotnet-ef` — install EF CLI globally
- `dotnet tool install -g dotnet-outdated-tool` — check for outdated packages
- `dotnet outdated` — list outdated NuGet packages

## Production
- `dotnet publish -c Release --self-contained -r linux-x64` — self-contained publish
- `dotnet publish -c Release -p:PublishTrimmed=true` — trimmed publish (smaller binary)
