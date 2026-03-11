# Kotlin Patterns

## Null Safety
- Use `?.` safe calls and `?:` elvis operator — avoid `!!` except in tests
- Prefer `val` over `var` — immutability by default
- Use `let`, `run`, `also`, `apply` scope functions appropriately
- Use `requireNotNull()` / `checkNotNull()` for preconditions

## Coroutines
- Use `suspend` functions for async operations
- Use `Flow` for reactive streams — prefer over callbacks
- Use `CoroutineScope` tied to lifecycle (viewModelScope, lifecycleScope)
- Handle cancellation properly — check `isActive` in loops
- Use `withContext(Dispatchers.IO)` for blocking I/O

## Data Classes & Sealed Classes
- Use `data class` for value objects — get `equals`, `hashCode`, `copy` for free
- Use `sealed class` / `sealed interface` for restricted hierarchies
- Prefer sealed classes over enums when variants carry different data
- Use `when` exhaustively with sealed types — compiler enforces completeness

## Idioms
- Use `also` for side effects: `return result.also { log(it) }`
- Use `takeIf` / `takeUnless` for conditional returns
- Prefer extension functions over utility classes
- Use `object` for singletons, `companion object` for factory methods
- Use destructuring: `val (name, age) = person`

## Android-Specific
- Use ViewModel + StateFlow for UI state
- Use Hilt/Koin for dependency injection
- Use Room for local persistence with Flow queries
- Avoid blocking the main thread — use lifecycleScope.launch
