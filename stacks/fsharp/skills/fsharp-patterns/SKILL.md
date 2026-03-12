# F# Patterns

## Type System
- Use discriminated unions to model domain states — exhaustive matching catches missing cases
- Use record types for data — they are immutable by default and support structural equality
- Leverage `Option<'T>` instead of null — use `Option.map`, `Option.bind`, `Option.defaultValue`
- Use `Result<'T, 'E>` for operations that can fail with a typed error
- Use single-case discriminated unions for type-safe identifiers: `type UserId = UserId of int`

## Functional Style
- Prefer immutable data and `let` bindings — use `mutable` only when interacting with .NET APIs
- Use the `|>` pipe operator for left-to-right data transformations
- Leverage pattern matching over if/else chains for multi-branch logic
- Use `Seq`, `List`, and `Array` modules for collection processing
- Use computation expressions (`async { }`, `task { }`, `result { }`) for monadic workflows

## Error Handling
- Use `Result<'T, 'E>` in domain logic — avoid exceptions for expected failures
- Use `Result.map`, `Result.bind` or the `result { }` computation expression
- Reserve `try/with` for truly exceptional cases and .NET interop boundaries
- Define domain error types as discriminated unions

## Project Structure
- Organize files top-to-bottom in the `.fsproj` — F# requires declaration before use
- Keep domain types and logic in a core library, IO at the edges
- Use `module` declarations for related functions, `namespace` for organizing types
- Separate pure domain logic from infrastructure concerns

## Testing
- Use `Expecto` or `xUnit` with `FsUnit` for idiomatic test assertions
- Use `FsCheck` for property-based testing
- Test pure functions directly — mock IO dependencies via function parameters
- Organize tests by module, mirroring the source structure
