# F# Style Rules

## Formatting
- Use `fantomas` for consistent formatting — configure via `.editorconfig` or `fantomas-config`
- 4-space indentation (F# convention)
- Keep lines under 120 characters
- One blank line between top-level definitions

## Naming
- Functions and values: `camelCase` (`calculateTotal`, `userId`)
- Types, modules, namespaces: `PascalCase` (`OrderService`, `ValidationError`)
- Type parameters: `'a`, `'b` or descriptive `'TKey`, `'TValue`
- DU cases: `PascalCase` (`Pending`, `Confirmed`)
- Private module functions: `camelCase` (no underscore prefix)

## Types
- Prefer discriminated unions over class hierarchies for domain modeling
- Use record types for data — they provide structural equality and immutability by default
- Use single-case DUs for type-safe identifiers: `type OrderId = OrderId of Guid`
- Avoid `mutable` in domain logic — use immutable records with copy-and-update: `{ order with Status = Shipped }`
- Use `Option<'T>` instead of null — leverage `Option.map`, `Option.bind`, `Option.defaultValue`
- Use `Result<'T,'E>` for operations that can fail with a typed error

## Functions and Pipelines
- Keep the `|>` pipeline readable — one transformation per line for chains over 3 steps
- Use partial application and currying to build specialized functions
- Prefer `function` keyword for immediate pattern match on the last parameter
- Use explicit type annotations on public API functions
- Avoid `ignore` — if a function returns a value, handle it or explain why it is discarded

## File Organization
- Order files in `.fsproj` from foundational types to high-level orchestration
- F# requires declaration before use — files compile in .fsproj order
- One module or namespace per file
- Place types first, then functions that operate on them

## Error Handling
- Use `Result<'T,'E>` in domain logic — avoid exceptions for expected failures
- Use computation expressions (`result { }`) for chaining fallible operations
- Reserve `try/with` for .NET interop and truly exceptional cases
- Define domain error types as discriminated unions

## Documentation
- Add XML doc comments (`///`) to public types and functions
- Include `<param>`, `<returns>`, `<example>` tags for complex APIs
- Use `[<Obsolete>]` attribute for deprecated functions

## Linting
- Run `dotnet build` with warnings enabled — treat warnings as errors in CI
- Use `fantomas --check .` in CI to enforce formatting
- Prefer `Ionide` or `Rider` for real-time diagnostics during development
