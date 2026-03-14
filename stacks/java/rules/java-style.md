# Java Style Rules

## Language Version
- Target Java 21+ for new projects — use records, sealed classes, pattern matching, and virtual threads
- For legacy codebases, target Java 17 as the minimum LTS baseline
- Use `--enable-preview` only in development — never ship preview features in production

## Naming Conventions
- Classes and interfaces: `PascalCase` — e.g., `UserService`, `OrderRepository`
- Methods and variables: `camelCase` — e.g., `findById`, `userName`
- Constants: `UPPER_SNAKE_CASE` — e.g., `MAX_RETRIES`, `DEFAULT_TIMEOUT`
- Packages: all lowercase, reverse domain — e.g., `com.example.users.service`
- Type parameters: single uppercase letter with meaning — `T` (type), `E` (element), `K` (key), `V` (value)
- Boolean methods: prefix with `is`, `has`, `can`, `should` — e.g., `isActive()`, `hasPermission()`

## Immutability
- Use `record` for all data-carrying types — they are final and immutable by default
- Use `final` on local variables that are not reassigned — configure IDE/linter to enforce
- Return `List.of()`, `Map.of()`, `Set.of()` unmodifiable collections — never return mutable internal state
- Use `List.copyOf()` in constructors to defensively copy mutable input collections
- Prefer `String.formatted()` over `String.format()` — instance method is cleaner

## Null Handling
- Never return `null` from public methods — use `Optional<T>` for single values, empty collections for lists
- Use `Optional` only as return types — never as fields, parameters, or collection elements
- Validate non-null preconditions: `Objects.requireNonNull(param, "param must not be null")`
- Use `@Nullable` and `@NonNull` annotations from `jakarta.annotation` or `org.jspecify`

## Error Handling
- Use unchecked exceptions (`RuntimeException` subclasses) for all domain errors
- Reserve checked exceptions for truly recoverable I/O boundaries you cannot abstract away
- Create a domain exception hierarchy rooted in a single base class
- Always include the cause when wrapping exceptions: `new AppException("msg", cause)`
- Never catch `Exception` or `Throwable` broadly — catch specific types

## Stream and Collection Usage
- Prefer `stream()` pipelines over imperative loops for transformations and filtering
- Use `toList()` (Java 16+) instead of `Collectors.toList()` — returns unmodifiable list
- Use parallel streams only for CPU-bound work with large datasets (>10k elements) — never for I/O
- Do not mutate external state inside stream operations — streams assume stateless lambdas

## Concurrency
- Use virtual threads for I/O-bound work — do not pool them
- Replace `synchronized` blocks with `ReentrantLock` when using virtual threads
- Use `ConcurrentHashMap.computeIfAbsent` for thread-safe lazy initialization
- Never use `Thread.stop()`, `Thread.suspend()`, or `Thread.resume()`

## Dependencies and Build
- Prefer constructor injection over field injection in Spring — makes dependencies explicit and testable
- Minimize dependency scope: use `implementation` not `api` in Gradle, `provided` in Maven where possible
- Keep `pom.xml` / `build.gradle` dependencies sorted alphabetically within scope groups
- Pin dependency versions — use a BOM (Bill of Materials) for consistent transitive versions

## Testing
- Name tests as `should<Expected>_when<Condition>` — e.g., `shouldReturnUser_whenIdExists`
- Use AssertJ over JUnit assertions — fluent API is more readable and produces better failure messages
- Use `@ParameterizedTest` for testing multiple inputs against the same assertion
- Keep unit tests isolated — mock external dependencies, do not start Spring context

## Records and Sealed Types
- Use `record` for all data transfer objects, value objects, and multi-return types
- Add compact constructors in records for validation — do not create separate builder classes for records
- Use `sealed interface` with `permits` for closed type hierarchies — enables exhaustive switch
- Prefer records as sealed interface implementations — they get `equals`/`hashCode`/`toString` for free

## Logging
- Use SLF4J as the logging facade — never use `System.out.println` in production code
- Use parameterized messages: `log.info("User {} logged in", userId)` — not string concatenation
- Log at appropriate levels: `ERROR` for failures, `WARN` for degradation, `INFO` for events, `DEBUG` for diagnostics
- Include relevant context (IDs, counts) in log messages — but never log sensitive data (passwords, tokens)

## Formatting
- Use 4-space indentation — no tabs
- Maximum line length: 120 characters
- Opening braces on the same line (K&R style)
- One blank line between methods, two blank lines between class sections (fields, constructors, methods)
- Use Google Java Format or Palantir Java Format — enforce in CI with `spotless` or `checkstyle`
- Import ordering: static imports first, then `java.*`, then `javax.*`, then third-party, then project — separated by blank lines
- Remove unused imports — configure IDE and CI to enforce
