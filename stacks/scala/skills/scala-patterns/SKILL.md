# Scala Patterns

## Type System
- Use sealed traits for exhaustive pattern matching
- Prefer case classes for immutable data — they provide `equals`, `hashCode`, and `copy` for free
- Use type aliases to clarify complex types: `type UserId = String`
- Leverage `Option[T]` instead of null — pattern match or use `map`/`flatMap`
- Use `Either[L, R]` for computations that can fail with a typed error

## Functional Style
- Prefer immutable collections — use `val` over `var`
- Chain transformations with `map`, `flatMap`, `filter` instead of loops
- Use for-comprehensions to flatten nested `map`/`flatMap` chains
- Avoid side effects in pure functions — isolate IO at the edges
- Use partial functions with `collect` for combined filter-and-map

## Error Handling
- Use `Try[T]` for wrapping exceptions from Java interop
- Prefer `Either[Error, T]` over throwing exceptions in business logic
- Use `recover` and `recoverWith` on `Future` for async error handling
- Avoid `get` on `Option` or `Try` — always pattern match or use `getOrElse`

## Concurrency
- Use `Future` with an explicit `ExecutionContext` — never use `global`
- Prefer Akka Actors or ZIO/Cats Effect for complex concurrent workflows
- Avoid blocking inside `Future` — use `blocking { }` if unavoidable
- Use `Promise` to bridge callback-based APIs into `Future`

## Project Structure
- Organize by domain, not by layer — `com.example.orders`, not `com.example.models`
- Keep `build.sbt` clean — extract common settings into `project/` plugins
- Use multi-project builds for large codebases
- Place integration tests in `src/it/scala` with a separate configuration
