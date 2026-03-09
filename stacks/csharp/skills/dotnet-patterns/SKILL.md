# .NET / C# Patterns

## Dependency Injection
- Register services in `Program.cs` or `Startup.cs` using the built-in DI container
- Use constructor injection — avoid service locator pattern
- Register scoped services for per-request lifetime, singletons for shared state
- Use `IOptions<T>` pattern for configuration binding

## Async/Await
- Use `async Task` for async methods, `async Task<T>` for those returning values
- Always use `ConfigureAwait(false)` in library code
- Never use `.Result` or `.Wait()` — it causes deadlocks
- Use `ValueTask` for hot paths that often complete synchronously
- Suffix async method names with `Async`

## Entity Framework
- Use migrations for schema changes: `dotnet ef migrations add <Name>`
- Use `AsNoTracking()` for read-only queries
- Avoid lazy loading — use explicit `.Include()` for related data
- Keep DbContext lifetime short (scoped per request)

## Error Handling
- Use `ProblemDetails` for API error responses
- Use middleware for global exception handling
- Create domain-specific exception types
- Use `Result<T>` pattern for expected failures instead of exceptions

## Testing
- Use xUnit for unit tests, `WebApplicationFactory` for integration tests
- Use `Moq` or `NSubstitute` for mocking interfaces
- Use `Bogus` for generating test data
- Test controllers through HTTP using `HttpClient` from test server
