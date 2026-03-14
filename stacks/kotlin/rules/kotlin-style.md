# Kotlin Style Rules

## Immutability
- Use `val` over `var` by default — only use `var` when reassignment is genuinely needed
- Use immutable collections (`List`, `Map`, `Set`) in public APIs — use `Mutable*` variants only internally
- Use `data class` with all `val` properties for value objects and DTOs
- Use `copy()` for creating modified instances — never expose mutable state

## Null Safety
- Avoid `!!` in production code — it is acceptable only in tests where null indicates a test bug
- Use `?.let { }` for scoped null-safe operations, `?:` for providing defaults
- Use `requireNotNull()` and `checkNotNull()` at function boundaries with descriptive messages
- Annotate Java interop types explicitly as `String?` or `String` — never trust platform types

## Naming Conventions
- Classes, interfaces, objects: `PascalCase` — e.g., `UserRepository`, `NetworkResult`
- Functions, properties, variables: `camelCase` — e.g., `fetchUser`, `isActive`
- Constants: `UPPER_SNAKE_CASE` for compile-time constants, `camelCase` for runtime vals
- Backing properties: prefix with underscore — `private val _state`, public `val state`
- Extension functions: name as if they were member functions of the receiver type
- Test functions: use backtick syntax — `` `should return user when id exists` ``

## Functions
- Use expression bodies for single-expression functions: `fun double(x: Int) = x * 2`
- Use named arguments when calling functions with more than two parameters of the same type
- Prefer default parameter values over method overloads
- Use `when` instead of `if-else` chains for three or more branches
- Use scope functions idiomatically: `apply` for configuration, `also` for side effects, `let` for null-safe transforms, `run` for scoped computation

## Coroutines
- Always use structured concurrency — tie coroutines to a meaningful `CoroutineScope`
- Never use `GlobalScope` in production — it causes coroutine leaks
- Use `Dispatchers.IO` for blocking I/O, `Dispatchers.Default` for CPU, `Dispatchers.Main` for UI
- Use `withContext` to switch dispatchers — do not launch a new coroutine just to change context
- Handle `CancellationException` correctly — never swallow it, always rethrow

## Error Handling
- Use `runCatching` and `Result<T>` for operations that may fail — chain with `map`, `recover`, `getOrElse`
- Use sealed interfaces for domain-specific error hierarchies
- Use `require()` for argument validation, `check()` for state validation — both throw `IllegalArgumentException` / `IllegalStateException`
- Never catch `Exception` broadly — catch specific types and let `CancellationException` propagate

## Sealed Types and Data Classes
- Use `sealed interface` over `sealed class` when no shared state is needed — more flexible for implementors
- Prefer `data object` for singleton sealed subtypes — e.g., `data object Loading : UiState`
- Do not use `data class` for mutable entities — data classes assume value semantics
- Use `copy()` for creating modified instances — never make data class properties `var`

## Code Organization
- One top-level declaration per file for classes — extension functions and small helpers can share a file
- Group related extension functions in a file named `<Type>Extensions.kt`
- Order class members: properties, init blocks, constructors, public methods, private methods, companion object
- Use `internal` visibility for module-private APIs — prefer it over `public` when cross-module access is not needed
- Limit files to ~300 lines — split when complexity grows

## Testing
- Use backtick test names: `` `should return user when id is valid` `` — reads as specification
- Use `kotest` or JUnit 5 — both support coroutine testing with `runTest`
- Use `turbine` for testing `Flow` emissions — provides `awaitItem()`, `awaitComplete()`, `awaitError()`
- Use `MockK` over Mockito for Kotlin — it handles suspend functions, extension functions, and `object` natively
- Test coroutines with `runTest { }` — it auto-advances virtual time and detects leaked coroutines

## Kotlin-Java Interop
- Annotate public API with `@JvmStatic`, `@JvmField`, `@JvmOverloads` when consumed from Java
- Use `@Throws(IOException::class)` on functions that throw checked exceptions called from Java
- Avoid companion object functions for Java interop — use top-level functions or `@JvmStatic`

## Formatting
- Use `ktlint` or `detekt` formatting rules — enforce in CI
- 4-space indentation, no tabs
- Maximum line length: 120 characters
- Trailing commas in multiline parameter lists, argument lists, and when branches
- Blank line between functions, no blank lines inside single-expression functions
- Import ordering: `java.*`, `javax.*`, `kotlin.*`, third-party, project — no wildcard imports
- Remove unused imports — configure IDE and detekt to enforce
