# Swift Style Rules

## Naming

- Types and protocols: `UpperCamelCase` (`UserProfile`, `Cacheable`)
- Functions, variables, properties: `lowerCamelCase` (`fetchUser`, `isValid`)
- Constants: `lowerCamelCase` (`let maxRetryCount = 3`), not `SCREAMING_SNAKE`
- Acronyms: uppercase when all-caps would be 2 chars (`ID`, `URL`), otherwise title case (`Http`)
- Factory methods: name after the returned type (`makeIterator()`, `makeBody()`)
- Boolean properties: read as assertions (`isEmpty`, `hasContent`, `canSubmit`)
- Protocols: capability nouns (`Equatable`, `Codable`) or role nouns (`Delegate`, `DataSource`)

## File Structure

- One primary type per file; name the file after that type
- Group related extensions in the same file or in `TypeName+Category.swift`
- File order: type declaration, then protocol conformances as extensions, then private helpers
- Keep `import` statements alphabetized; separate Foundation/system from third-party

## Module Organization

- Use Swift packages with clear module boundaries
- Internal implementation goes in non-exported files; public API uses `public` access control
- Use `@testable import` in tests to access `internal` symbols — do not make things `public` just for tests
- Prefer `internal` (default) access; use `private` and `fileprivate` to limit scope within a file

## Immutability

- Default to `let`; use `var` only when mutation is required
- Mark types as `struct` unless identity or inheritance is needed
- Use `Sendable` and value types to eliminate shared mutable state
- Prefer computed properties over stored mutable state when the value derives from other properties

## Control Flow

- Use `guard` for preconditions and early exits
- Use `if let` / `if case` for non-exit optional binding
- Prefer `switch` exhaustiveness over `default` when the set of cases is known
- Use `defer` for cleanup (closing files, unlocking locks)

## Closures and Functions

- Use trailing closure syntax for the last (or only) closure parameter
- Omit parameter labels in closures when the meaning is clear: `names.sorted { $0 < $1 }`
- Prefer method references when they read well: `names.forEach(print)`
- Avoid closures longer than ~15 lines — extract into a named function

## Error Handling

- Use `throws` for operations that can fail; reserve `fatalError` for programmer errors
- Prefer typed throws (Swift 6) when the error set is bounded
- Use `Result` for synchronous code that returns success or failure without throwing
- Document thrown errors in the function's doc comment

## Concurrency

- Mark UI code with `@MainActor`; never use `DispatchQueue.main` in async code
- Make types `Sendable` when they cross isolation boundaries
- Use `async/await` for new asynchronous code; avoid callback-based APIs
- Enable strict concurrency checking: `-strict-concurrency=complete`

## Documentation

- All public API must have `///` doc comments
- Include a brief summary line, parameter descriptions, return value, and throws clause
- Use `- Parameter name:` and `- Returns:` and `- Throws:` markup
- Add `// MARK: -` sections to group related code in long files

## Testing

- Name tests descriptively: `testFetchUser_withInvalidID_throwsNotFound()`
- Use Swift Testing (`@Test`, `#expect`) for new tests; XCTest for existing test suites
- One assertion per test when practical; multiple related assertions are fine
- Use `@Suite` to group related tests; use tags for filtering
- Test both success and failure paths

## Formatting

- Use Xcode's default formatting or `swift-format`
- 4-space indentation, no tabs
- Opening braces on the same line as the declaration
- Maximum line length: 120 characters
- No trailing whitespace; files end with a newline
