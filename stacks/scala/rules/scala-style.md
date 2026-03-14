# Scala Style Rules

## Naming
- Types, classes, traits, objects: `PascalCase`
- Methods, values, variables: `camelCase`
- Constants: `PascalCase` (not UPPER_SNAKE — Scala convention)
- Type parameters: single uppercase letter (`A`, `B`) or descriptive (`Key`, `Value`)
- Package names: `lowercase`, matching directory structure
- Boolean methods: `isEmpty`, `hasPermission`, `canAccess` — no `get` prefix

## Formatting
- Use `scalafmt` with a `.scalafmt.conf` in the project root
- 2 spaces for indentation
- Max line length: 100-120 characters
- Use trailing commas in multi-line parameter lists and sequences
- Use Scala 3 indentation syntax where it improves readability

## Type System
- Use `sealed` on base traits/enums when all subtypes are in the same file
- Prefer case classes for data, regular classes for behavior with mutable state
- Use `opaque type` for zero-cost type-safe wrappers
- Use `given`/`using` (Scala 3) over `implicit` — clearer intent
- Avoid `Any`, `AnyRef`, `asInstanceOf` — use pattern matching instead

## Functional Idioms
- Avoid `return` statements — the last expression is the return value
- Avoid `null` — use `Option`, `Either`, or domain-specific types
- Prefer `val` over `var`; prefer immutable collections
- Use for-comprehensions for chaining monadic operations (Option, Either, Future)
- Use `match` with exhaustive patterns over `if/else` chains
- Avoid wildcard imports (`import foo.*`) in production code — import explicitly

## Error Handling
- Use `Either[Error, A]` for expected failures with error information
- Use `Option` for values that may be absent
- Reserve exceptions for truly exceptional/unrecoverable situations
- Use typed error channels (ZIO, Cats Effect) when available
- Never catch `Throwable` or `Exception` broadly

## Methods
- Keep methods short — extract helpers as private methods or local functions
- Use named parameters for methods with multiple parameters of the same type
- Use extension methods (Scala 3) instead of implicit classes
- Add ScalaDoc (`/** */`) to public API methods and classes
