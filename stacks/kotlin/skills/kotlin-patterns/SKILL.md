# Kotlin Patterns

## Null Safety Mastery

### Safe Call Chains and Elvis
```kotlin
// Chain safe calls — short-circuits to null on first null
val cityLength: Int? = user?.address?.city?.length

// Elvis with early return — idiomatic for preconditions
fun processUser(id: String): Result<User> {
    val user = repo.findById(id) ?: return Result.failure(NotFoundException("User $id"))
    val email = user.email ?: return Result.failure(ValidationError("No email"))
    return Result.success(user)
}

// Elvis with throw for non-optional contexts
val config = loadConfig() ?: throw IllegalStateException("Config missing")
```

### Smart Casts and Contracts
```kotlin
// Smart cast after type check
fun describe(obj: Any): String = when (obj) {
    is String -> "String of length ${obj.length}"  // Smart cast to String
    is Int -> "Integer: ${obj * 2}"                 // Smart cast to Int
    is List<*> -> "List with ${obj.size} items"
    else -> obj.toString()
}

// Custom contracts for smart casts
@OptIn(ExperimentalContracts::class)
fun requireNotBlank(value: String?): String {
    contract { returns() implies (value != null) }
    require(!value.isNullOrBlank()) { "Value must not be blank" }
    return value  // Smart cast: value is String after contract
}
```

### Platform Type Interop
```kotlin
// Java methods return platform types (T!) — explicitly annotate nullability
// WRONG — trusting platform type
val name = javaObject.getName()  // Type is String! — could be null at runtime

// RIGHT — handle explicitly
val name: String = javaObject.getName() ?: "default"
val name: String? = javaObject.getName()  // Declare nullable if unsure
```

## Coroutines: Structured Concurrency

### Basic Patterns
```kotlin
// Parallel decomposition — both tasks run concurrently
suspend fun fetchProfile(id: String): UserProfile = coroutineScope {
    val user = async { userService.fetch(id) }
    val orders = async { orderService.fetchForUser(id) }
    UserProfile(user.await(), orders.await())
}

// If either fails, the other is automatically cancelled (structured concurrency)

// Sequential when needed — no async overhead
suspend fun processSequential(items: List<Item>) {
    for (item in items) {
        process(item)  // Suspends, does not block thread
    }
}
```

### SupervisorScope and Exception Handling
```kotlin
// supervisorScope — failure of one child does not cancel siblings
suspend fun fetchAll(ids: List<String>): List<Result<User>> = supervisorScope {
    ids.map { id ->
        async {
            runCatching { userService.fetch(id) }
        }
    }.awaitAll()
}

// Exception handler for fire-and-forget coroutines
val handler = CoroutineExceptionHandler { _, exception ->
    logger.error("Unhandled coroutine exception", exception)
}

scope.launch(handler) {
    // If this throws, handler is invoked instead of crashing
    riskyOperation()
}
```

### Cancellation
```kotlin
// Cooperative cancellation — check isActive in CPU-bound loops
suspend fun processLargeDataset(items: List<Item>) = coroutineScope {
    for (item in items) {
        ensureActive()  // Throws CancellationException if cancelled
        process(item)
    }
}

// withTimeout — auto-cancel after deadline
val result = withTimeoutOrNull(5.seconds) {
    slowNetworkCall()
} ?: fallbackValue

// Clean up on cancellation
suspend fun managedResource() {
    val resource = acquire()
    try {
        useResource(resource)
    } finally {
        withContext(NonCancellable) {
            resource.close()  // Runs even if coroutine is cancelled
        }
    }
}
```

## Flow Patterns

### Creating and Transforming Flows
```kotlin
// Cold flow — emits fresh values for each collector
fun observeUsers(): Flow<List<User>> = flow {
    while (true) {
        emit(userRepo.fetchAll())
        delay(30.seconds)
    }
}

// Operators
userFlow
    .map { users -> users.filter { it.isActive } }
    .distinctUntilChanged()
    .debounce(300.milliseconds)
    .catch { e -> emit(emptyList()) }  // Handle upstream errors
    .onEach { users -> logger.info("Active users: ${users.size}") }
    .flowOn(Dispatchers.IO)  // Upstream runs on IO dispatcher
    .collect { users -> updateUI(users) }
```

### StateFlow and SharedFlow
```kotlin
class UserViewModel : ViewModel() {
    // StateFlow — always has a current value, replays latest to new collectors
    private val _state = MutableStateFlow<UiState>(UiState.Loading)
    val state: StateFlow<UiState> = _state.asStateFlow()

    // SharedFlow — for events that should not be replayed
    private val _events = MutableSharedFlow<UiEvent>()
    val events: SharedFlow<UiEvent> = _events.asSharedFlow()

    fun loadUsers() {
        viewModelScope.launch {
            _state.value = UiState.Loading
            runCatching { userRepo.fetchAll() }
                .onSuccess { _state.value = UiState.Success(it) }
                .onFailure { _state.value = UiState.Error(it.message ?: "Unknown") }
        }
    }

    fun onAction(action: UserAction) {
        viewModelScope.launch {
            _events.emit(UiEvent.ShowToast("Processing..."))
        }
    }
}

// Combining multiple flows
val combined: Flow<ScreenState> = combine(
    userFlow, settingsFlow, networkFlow
) { users, settings, isOnline ->
    ScreenState(users, settings, isOnline)
}
```

### Channels
```kotlin
// Fan-out: multiple coroutines consuming from one channel
val channel = Channel<Task>(capacity = Channel.BUFFERED)

// Producer
launch { tasks.forEach { channel.send(it) }; channel.close() }

// Multiple consumers
repeat(4) { workerId ->
    launch {
        for (task in channel) {
            logger.info("Worker $workerId processing ${task.id}")
            process(task)
        }
    }
}
```

## Sealed Classes and Algebraic Data Types

### Exhaustive State Modeling
```kotlin
sealed interface NetworkResult<out T> {
    data class Success<T>(val data: T) : NetworkResult<T>
    data class Error(val code: Int, val message: String) : NetworkResult<Nothing>
    data object Loading : NetworkResult<Nothing>
}

// Exhaustive when — compiler enforces all branches
fun <T> NetworkResult<T>.fold(
    onSuccess: (T) -> Unit,
    onError: (Int, String) -> Unit,
    onLoading: () -> Unit
) = when (this) {
    is NetworkResult.Success -> onSuccess(data)
    is NetworkResult.Error -> onError(code, message)
    is NetworkResult.Loading -> onLoading()
}
```

### Sealed with Data Classes for Command Pattern
```kotlin
sealed interface Command {
    data class CreateUser(val name: String, val email: String) : Command
    data class DeleteUser(val id: String) : Command
    data class UpdateEmail(val id: String, val newEmail: String) : Command
}

fun execute(cmd: Command): Result<Unit> = when (cmd) {
    is Command.CreateUser -> createUser(cmd.name, cmd.email)
    is Command.DeleteUser -> deleteUser(cmd.id)
    is Command.UpdateEmail -> updateEmail(cmd.id, cmd.newEmail)
}
```

## Delegation and Extension Functions

### Property Delegation
```kotlin
// Lazy initialization — thread-safe by default
val expensiveValue: ExpensiveObject by lazy { computeExpensive() }

// Map delegation — useful for dynamic config
class Config(private val map: Map<String, Any>) {
    val host: String by map
    val port: Int by map
}
val config = Config(mapOf("host" to "localhost", "port" to 8080))
```

### Extension Functions
```kotlin
// Add methods to existing types without inheritance
fun String.toSlug(): String =
    lowercase().replace(Regex("[^a-z0-9]+"), "-").trim('-')

// Extension on generic types with constraints
fun <T : Comparable<T>> List<T>.isSorted(): Boolean =
    zipWithNext().all { (a, b) -> a <= b }

// Extension properties
val <T> List<T>.lastIndex: Int get() = size - 1

// Scoping extensions to a receiver
class DatabaseContext {
    fun String.asColumn(): Column = Column(this)  // Only available inside DatabaseContext
}
```

## Inline Functions and Value Classes

### Inline and Reified
```kotlin
// Inline eliminates lambda allocation — reified enables runtime type access
inline fun <reified T> decodeJson(json: String): T =
    objectMapper.readValue(json, T::class.java)

val user: User = decodeJson(jsonString)  // No Class<T> parameter needed
```

### Value Classes
```kotlin
// Zero-overhead wrappers — compiled away to the underlying type
@JvmInline
value class UserId(val value: String) {
    init { require(value.isNotBlank()) { "UserId must not be blank" } }
}

@JvmInline
value class Email(val value: String) {
    init { require("@" in value) { "Invalid email: $value" } }
}

// Type safety without runtime allocation
fun getUser(id: UserId): User = repo.findById(id.value)
getUser(UserId("usr_123"))  // OK
// getUser(Email("a@b.com"))  // Compile error — Email is not UserId
```

## Performance Patterns

### Sequence vs Collection
```kotlin
// Collection — each operation creates an intermediate list
val result = list
    .map { it * 2 }       // Allocates new list
    .filter { it > 10 }   // Allocates another list
    .take(5)              // Allocates yet another list

// Sequence — lazy evaluation, single pass, no intermediate allocations
val result = list.asSequence()
    .map { it * 2 }
    .filter { it > 10 }
    .take(5)              // Stops after finding 5 matches
    .toList()             // Single allocation at the end

// Rule: use sequences when chaining 3+ operations on large collections (>1000 elements)
// For small collections or 1-2 operations, regular collections are faster (no overhead)
```

### Coroutine Dispatcher Sizing
```kotlin
// IO dispatcher: 64 threads by default — for blocking I/O
// Default dispatcher: core count threads — for CPU-bound work
// Never use Dispatchers.IO for CPU work or Dispatchers.Default for blocking I/O

// Custom limited dispatcher for rate-limiting
val dbDispatcher = Dispatchers.IO.limitedParallelism(10)  // Max 10 concurrent DB calls

// Main dispatcher: UI thread (Android) — use for UI updates only
withContext(Dispatchers.Main) { updateUI(result) }
```

## Common Pitfalls

### Data Class Copy Trap
```kotlin
data class User(val name: String, val roles: MutableList<String>)

val original = User("Alice", mutableListOf("admin"))
val copy = original.copy()  // Shallow copy — roles list is shared!
copy.roles.add("editor")
println(original.roles)  // [admin, editor] — mutated through copy

// FIX: use immutable collections in data classes
data class User(val name: String, val roles: List<String>)
```

### GlobalScope Leak
```kotlin
// WRONG — GlobalScope lives forever, leaks coroutines
GlobalScope.launch { fetchData() }

// RIGHT — use a scoped CoroutineScope and cancel it on shutdown
val scope = CoroutineScope(Dispatchers.Default + SupervisorJob())
scope.launch { fetchData() }
scope.cancel() // On shutdown
```
