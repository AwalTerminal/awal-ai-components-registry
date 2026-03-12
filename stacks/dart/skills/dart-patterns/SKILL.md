# Dart Patterns

## Type System
- Use sound null safety — annotate nullable types with `?` and handle them explicitly
- Use `sealed class` for exhaustive pattern matching (Dart 3+)
- Prefer `final` for local variables that aren't reassigned
- Use `typedef` for complex function signatures
- Leverage records and patterns for destructuring: `var (name, age) = getUser();`

## Error Handling
- Throw typed exceptions — define custom exception classes for domain errors
- Use `try/catch` with specific exception types, not bare `catch`
- Return `Result`-style types for expected failures in library APIs
- Use `Future.catchError` or `try/catch` in async code — never ignore failed futures

## Async Programming
- Use `async`/`await` for all asynchronous operations
- Use `Stream` for event-based data — `StreamController` to create custom streams
- Use `Future.wait` for parallel async operations
- Use `Completer` to bridge callback-based APIs into futures
- Cancel streams with `StreamSubscription.cancel` to prevent leaks

## Project Structure
- Use `lib/` for library code, `bin/` for executables, `test/` for tests
- Export public API from a single barrel file: `lib/my_package.dart`
- Use `part`/`part of` sparingly — prefer separate library files with imports
- Keep `pubspec.yaml` clean — pin major versions with `^` syntax

## Testing
- Use the `test` package — organize with `group` and `test`
- Use `mockito` or `mocktail` for mocking dependencies
- Test async code with `expectLater` and matchers like `emitsInOrder`
- Run tests with `dart test` — use `--coverage` for coverage reports
