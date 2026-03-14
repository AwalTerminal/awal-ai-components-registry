# Java Patterns

## Modern Language Features (Java 17+)

### Records
Immutable data carriers — replace boilerplate POJOs:
```java
public record User(String name, String email, Instant createdAt) {
    // Compact constructor for validation
    public User {
        Objects.requireNonNull(name, "name must not be null");
        Objects.requireNonNull(email, "email must not be null");
        if (!email.contains("@")) throw new IllegalArgumentException("Invalid email");
    }

    // Custom factory method
    public static User of(String name, String email) {
        return new User(name, email, Instant.now());
    }
}

// Records are final, implement equals/hashCode/toString automatically
// Use records for DTOs, value objects, and method return types with multiple values
```

### Sealed Classes and Pattern Matching
```java
public sealed interface Shape permits Circle, Rectangle, Triangle {
    double area();
}
public record Circle(double radius) implements Shape {
    public double area() { return Math.PI * radius * radius; }
}
public record Rectangle(double width, double height) implements Shape {
    public double area() { return width * height; }
}
public record Triangle(double base, double height) implements Shape {
    public double area() { return 0.5 * base * height; }
}

// Pattern matching with switch (Java 21+)
String describe(Shape shape) {
    return switch (shape) {
        case Circle c when c.radius() > 10 -> "Large circle r=" + c.radius();
        case Circle c -> "Circle r=" + c.radius();
        case Rectangle r -> "Rectangle %sx%s".formatted(r.width(), r.height());
        case Triangle t -> "Triangle b=" + t.base();
    };
}

// Pattern matching with instanceof
if (obj instanceof String s && s.length() > 5) {
    System.out.println(s.toUpperCase());
}
```

### Virtual Threads (Project Loom, Java 21+)
```java
// Replace thread pools for I/O-bound work — millions of virtual threads are cheap
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    List<Future<String>> futures = urls.stream()
        .map(url -> executor.submit(() -> fetchUrl(url)))
        .toList();

    List<String> results = futures.stream()
        .map(f -> {
            try { return f.get(); }
            catch (Exception e) { throw new RuntimeException(e); }
        })
        .toList();
}

// Structured concurrency (preview) — parent waits for all children
try (var scope = new StructuredTaskScope.ShutdownOnFailure()) {
    Subtask<User> user = scope.fork(() -> fetchUser(id));
    Subtask<List<Order>> orders = scope.fork(() -> fetchOrders(id));
    scope.join().throwIfFailed();
    return new UserProfile(user.get(), orders.get());
}

// PITFALL: Do not pool virtual threads — they are cheap to create
// PITFALL: Do not use synchronized blocks with virtual threads — use ReentrantLock
private final ReentrantLock lock = new ReentrantLock();
void safeMethod() {
    lock.lock();
    try { /* critical section */ }
    finally { lock.unlock(); }
}
```

## Stream API Mastery

### Advanced Collectors
```java
// Group and transform in a single pass
Map<Department, List<String>> namesByDept = employees.stream()
    .collect(Collectors.groupingBy(
        Employee::department,
        Collectors.mapping(Employee::name, Collectors.toList())
    ));

// Partition by predicate
Map<Boolean, List<Employee>> partitioned = employees.stream()
    .collect(Collectors.partitioningBy(e -> e.salary() > 100_000));

// Reduce to summary statistics
DoubleSummaryStatistics stats = employees.stream()
    .mapToDouble(Employee::salary)
    .summaryStatistics();
// stats.getAverage(), stats.getMax(), stats.getCount()

// Teeing collector — two collectors in one pass (Java 12+)
var result = employees.stream().collect(Collectors.teeing(
    Collectors.counting(),
    Collectors.averagingDouble(Employee::salary),
    (count, avgSalary) -> "Count: %d, Avg: %.2f".formatted(count, avgSalary)
));
```

### Stream Pitfalls
```java
// WRONG — stream consumed twice (IllegalStateException)
var stream = list.stream().filter(x -> x > 0);
stream.count();
stream.toList(); // Throws!

// WRONG — parallel streams for I/O (uses common ForkJoinPool, blocks all parallel streams)
urls.parallelStream().map(this::fetchUrl).toList();

// RIGHT — use virtual threads for I/O, parallel streams for CPU-bound work
// Parallel streams are only faster for large datasets (>10k elements) with CPU-heavy operations

// WRONG — modifying source during stream
list.stream().filter(x -> {
    list.add(x * 2); // ConcurrentModificationException
    return true;
}).toList();
```

## Optional Usage

### Correct Patterns
```java
// Chain transformations
Optional<String> city = getUser(id)
    .map(User::address)
    .map(Address::city);

// Provide alternatives
String name = findUser(id)
    .map(User::name)
    .orElse("Unknown");

// Conditional execution
findUser(id).ifPresentOrElse(
    user -> log.info("Found: {}", user),
    () -> log.warn("User {} not found", id)
);

// Flat-map nested optionals
Optional<License> license = findUser(id)
    .flatMap(User::driverLicense);
```

### Anti-patterns
```java
// WRONG — Optional for fields, parameters, or collections
class User { Optional<String> middleName; } // Use @Nullable or empty string

// WRONG — isPresent + get (defeats the purpose)
if (opt.isPresent()) { return opt.get(); }

// WRONG — Optional.of with nullable value (throws NPE)
Optional.of(possiblyNull); // Use Optional.ofNullable()

// WRONG — Optional in method parameters
void process(Optional<Filter> filter) {} // Use @Nullable or overloads
```

## Concurrency Patterns

### CompletableFuture Composition
```java
CompletableFuture<UserProfile> profile = CompletableFuture.supplyAsync(() -> fetchUser(id))
    .thenCombine(
        CompletableFuture.supplyAsync(() -> fetchOrders(id)),
        (user, orders) -> new UserProfile(user, orders)
    )
    .exceptionally(ex -> {
        log.error("Failed to build profile", ex);
        return UserProfile.empty();
    });

// Timeout handling (Java 9+)
CompletableFuture<String> withTimeout = fetchAsync()
    .orTimeout(5, TimeUnit.SECONDS)
    .exceptionally(ex -> "default");

// All-of with result collection
List<CompletableFuture<String>> futures = urls.stream()
    .map(url -> CompletableFuture.supplyAsync(() -> fetch(url)))
    .toList();

CompletableFuture.allOf(futures.toArray(CompletableFuture[]::new))
    .thenApply(v -> futures.stream().map(CompletableFuture::join).toList());
```

### Concurrent Collections
```java
// ConcurrentHashMap — lock striping, no full-table lock
ConcurrentHashMap<String, AtomicLong> counters = new ConcurrentHashMap<>();
counters.computeIfAbsent("hits", k -> new AtomicLong()).incrementAndGet();

// CopyOnWriteArrayList — fast reads, slow writes (good for event listeners)
List<EventListener> listeners = new CopyOnWriteArrayList<>();

// BlockingQueue for producer-consumer
BlockingQueue<Task> queue = new LinkedBlockingQueue<>(1000);
// Producer: queue.put(task) — blocks if full
// Consumer: Task t = queue.take() — blocks if empty
```

## Error Handling

### Checked vs Unchecked Strategy
```java
// Use unchecked exceptions for programming errors (bugs)
public User findById(String id) {
    Objects.requireNonNull(id, "id must not be null"); // NPE = bug
    return repo.findById(id)
        .orElseThrow(() -> new EntityNotFoundException("User", id));
}

// Custom exception hierarchy
public class DomainException extends RuntimeException {
    private final String code;
    public DomainException(String code, String message) {
        super(message);
        this.code = code;
    }
    public String code() { return code; }
}

public class EntityNotFoundException extends DomainException {
    public EntityNotFoundException(String entity, String id) {
        super("NOT_FOUND", "%s with id %s not found".formatted(entity, id));
    }
}

// Wrap checked exceptions at module boundaries
public byte[] readConfig(Path path) {
    try { return Files.readAllBytes(path); }
    catch (IOException e) { throw new ConfigException("Failed to read " + path, e); }
}
```

## Performance

### JVM Tuning
```bash
# G1GC (default Java 17+) — good for most workloads
java -XX:+UseG1GC -Xms512m -Xmx2g -XX:MaxGCPauseMillis=200
# ZGC — sub-millisecond pauses for large heaps
java -XX:+UseZGC -Xms4g -Xmx4g
```

### Common Hotspots
```java
// SLOW — String concatenation in loop (creates O(n) intermediate Strings)
String result = "";
for (String s : list) result += s;

// FAST — StringBuilder
StringBuilder sb = new StringBuilder(list.size() * 20);
for (String s : list) sb.append(s);

// FAST — String.join or Collectors.joining
String result = String.join(", ", list);

// SLOW — boxing in tight loops
for (int i = 0; i < 1_000_000; i++) {
    Integer boxed = i; // Autoboxing allocates
}
// Use primitive streams: IntStream, LongStream, DoubleStream
```

## Spring Boot Patterns

### Constructor Injection and Exception Handling
```java
@Service
public class OrderService {
    private final OrderRepository orders;
    private final PaymentGateway payments;

    // Single constructor — @Autowired not needed
    public OrderService(OrderRepository orders, PaymentGateway payments) {
        this.orders = orders;
        this.payments = payments;
    }
}

// Global error handling with ProblemDetail (RFC 7807)
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(EntityNotFoundException.class)
    public ProblemDetail handleNotFound(EntityNotFoundException ex) {
        ProblemDetail problem = ProblemDetail.forStatusAndDetail(
            HttpStatus.NOT_FOUND, ex.getMessage());
        problem.setProperty("code", ex.code());
        return problem;
    }
}
```

## Testing Patterns

### JUnit 5 with Mockito
```java
@ExtendWith(MockitoExtension.class)
class UserServiceTest {
    @Mock UserRepository repo;
    @InjectMocks UserService service;

    @Test
    void shouldReturnUser_whenExists() {
        var user = new User("1", "Alice", "alice@test.com");
        when(repo.findById("1")).thenReturn(Optional.of(user));
        assertThat(service.getUser("1")).isEqualTo(user);
    }

    @ParameterizedTest
    @ValueSource(strings = {"", " ", "not-an-email"})
    void shouldRejectInvalidEmails(String email) {
        assertThatThrownBy(() -> new User("1", "Alice", email))
            .isInstanceOf(IllegalArgumentException.class);
    }
}
```
