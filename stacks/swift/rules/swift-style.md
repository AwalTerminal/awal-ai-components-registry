# Swift Style Rules

- Use `let` over `var` whenever possible — default to immutability
- Use `guard` for early returns, `if let` for optional binding in non-exit paths
- Prefer value types (structs, enums) over reference types (classes) unless you need identity
- Use trailing closure syntax when the last parameter is a closure
- Use `@MainActor` for UI code, not `DispatchQueue.main`
- Prefer `async/await` over completion handlers in new code
- Use `Result` type for synchronous operations that can fail
- Mark types as `Sendable` when they cross concurrency boundaries
