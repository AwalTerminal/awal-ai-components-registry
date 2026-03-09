# Swift Concurrency

## Async/Await
- Use `async`/`await` over completion handlers for new code
- Mark functions `async throws` when they can fail
- Use `Task { }` to bridge from synchronous to async contexts
- Use `Task.detached` only when you explicitly need a different actor context

## Actors
- Use `actor` for mutable shared state — replaces manual lock management
- Use `@MainActor` for UI-related code
- Keep actor methods fast — offload heavy work to detached tasks
- Use `nonisolated` for properties/methods that don't access mutable state

## Structured Concurrency
- Prefer `async let` for parallel independent operations
- Use `TaskGroup` for dynamic numbers of concurrent tasks
- Always handle cancellation: check `Task.isCancelled` in loops
- Use `withThrowingTaskGroup` when child tasks can fail

## Common Patterns
- Use `AsyncSequence` / `AsyncStream` for event streams
- Prefer `Sendable` types for data crossing actor boundaries
- Avoid capturing `self` strongly in long-lived tasks
- Use `@TaskLocal` instead of thread-local storage

## Anti-Patterns
- Don't use `DispatchQueue` with async/await — they don't compose well
- Don't block an actor with synchronous I/O
- Don't create tasks in `init()` — use factory methods instead
- Don't use `unsafeSendable` unless you've proven safety
