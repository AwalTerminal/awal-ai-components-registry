# C# Style Rules

## Naming
- Types, methods, properties, events: `PascalCase`
- Parameters, local variables: `camelCase`
- Private fields: `_camelCase` (underscore prefix)
- Constants: `PascalCase` (not UPPER_SNAKE)
- Interfaces: prefix with `I` (`IOrderRepository`)
- Async methods: suffix with `Async` (`GetOrderAsync`)
- Boolean properties/methods: prefix with `Is`, `Has`, `Can` (`IsValid`, `HasItems`)

## Formatting
- 4 spaces for indentation, no tabs
- Braces on their own line (Allman style)
- One blank line between methods, no blank lines at start/end of blocks
- `using` directives at top of file, sorted alphabetically, System first
- Use file-scoped namespaces (`namespace App.Services;`) in modern C#

## Type System
- Enable nullable reference types project-wide (`<Nullable>enable</Nullable>`)
- Use `record` for immutable data types with value equality
- Use `readonly record struct` for small stack-allocated value types
- Prefer `init` over `set` for properties that should only be assigned at creation
- Use pattern matching over `is` + cast or `as` + null check

## Async
- Always use `async/await` — never `.Result` or `.Wait()` (causes deadlocks)
- Accept `CancellationToken` on all async public methods
- Use `ConfigureAwait(false)` in library code
- Use `ValueTask` only when profiling shows benefit

## Class Design
- Prefer primary constructors (C# 12) for simple dependency injection
- Use `sealed` by default — unseal only when inheritance is designed
- Limit constructor parameters to 4-5; extract if more
- Use `IOptions<T>` for configuration, not raw strings/values
- Prefer interfaces for external dependencies to enable testing

## Error Handling
- Use exceptions for unexpected failures; use `Result<T>` for expected ones
- Never catch `Exception` broadly — catch specific types
- Use `ProblemDetails` for API error responses
- Always include context in exception messages
