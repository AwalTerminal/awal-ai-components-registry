# Haskell Patterns

## Type System
- Use `newtype` wrappers to distinguish semantically different values of the same type
- Leverage type classes for ad-hoc polymorphism — define instances for your domain types
- Use `deriving` strategies (`stock`, `newtype`, `anyclass`) to reduce boilerplate
- Prefer concrete types in internal code, polymorphic signatures in library APIs
- Use `Data.Text` instead of `String` for all non-trivial text processing

## Error Handling
- Use `Either e a` for pure error handling — left for errors, right for success
- Use `ExceptT` to thread errors through monadic computations
- Avoid partial functions (`head`, `tail`, `fromJust`) — use safe alternatives
- Define custom error ADTs: `data AppError = NotFound | Unauthorized | ...`

## Functional Patterns
- Use point-free style sparingly — clarity over cleverness
- Leverage `where` and `let` bindings to name intermediate computations
- Use `Data.Map` and `Data.Set` from `containers` for efficient collections
- Prefer `foldl'` (strict left fold) over `foldl` to avoid space leaks
- Compose functions with `.` and apply with `$` to reduce parentheses

## Project Structure
- Use `stack` or `cabal` for reproducible builds
- Keep `Main.hs` minimal — delegate to library modules in `src/`
- Organize modules by domain: `MyApp.Auth`, `MyApp.Database`, `MyApp.API`
- Separate effectful code from pure logic — keep the pure core large

## Testing
- Use `hspec` or `tasty` for unit tests
- Use `QuickCheck` for property-based testing — define `Arbitrary` instances for domain types
- Test pure functions exhaustively, effectful functions at integration boundaries
- Use `hspec-discover` to auto-detect test files
