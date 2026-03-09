# Java Patterns

## Spring Boot
- Use constructor injection with `@RequiredArgsConstructor` (Lombok)
- Use `@Service`, `@Repository`, `@Controller` stereotypes appropriately
- Use `application.yml` with profiles for environment-specific config
- Use `@Transactional` at the service layer, not the repository layer

## Error Handling
- Use `@ControllerAdvice` with `@ExceptionHandler` for global error handling
- Create domain-specific exceptions extending `RuntimeException`
- Return `ResponseEntity` with appropriate HTTP status codes
- Use `Optional` return types instead of returning `null`

## Concurrency
- Use `CompletableFuture` for async operations
- Use `@Async` with a configured `TaskExecutor` for background tasks
- Use virtual threads (Java 21+) for I/O-bound workloads
- Prefer immutable objects for thread safety

## Data Access
- Use Spring Data JPA repositories for standard CRUD
- Use `@Query` with JPQL for custom queries
- Use pagination with `Pageable` for large result sets
- Use Flyway or Liquibase for database migrations

## Testing
- Use `@SpringBootTest` for integration tests
- Use `@WebMvcTest` for controller-only tests
- Use `@DataJpaTest` for repository tests with embedded DB
- Use Testcontainers for integration tests with real databases
