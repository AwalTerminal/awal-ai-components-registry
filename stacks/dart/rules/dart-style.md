# Dart Style Rules

## Formatting
- Run `dart format` before every commit — enforce in CI with `dart format --set-exit-if-changed .`
- Maximum line length: 80 characters (Dart formatter default)
- Use trailing commas in argument lists, parameter lists, and collection literals — triggers multiline formatting
- Let the formatter handle indentation — do not fight it with manual line breaks

## Naming Conventions
- Classes, enums, typedefs, extension types: `UpperCamelCase` — e.g., `UserService`, `NetworkResult`
- Variables, functions, parameters, named parameters: `lowerCamelCase` — e.g., `fetchUser`, `isActive`
- Constants and enum values: `lowerCamelCase` — e.g., `const maxRetries = 3`, not `MAX_RETRIES`
- Libraries and packages: `lowercase_with_underscores` — e.g., `my_package`, `user_service`
- Private members: prefix with underscore — `_internalState`, `_computeHash()`
- Boolean variables and getters: prefix with `is`, `has`, `can`, `should`

## Null Safety
- Use `final` for local variables that are not reassigned — prefer `final` over `var`
- Use null-aware operators (`?.`, `??`, `??=`) instead of manual `if (x != null)` checks
- Avoid `!` (null assertion) unless you can guarantee non-null and a comment explains why
- Assign nullable fields to local variables before null checks — enables type promotion

## Type Annotations
- Annotate all public API return types and parameter types explicitly
- Omit type annotations on local variables when the type is obvious from the initializer
- Use `dynamic` only when truly needed (e.g., JSON decoding) — prefer `Object?` for unknown types
- Specify generic type arguments when inference is ambiguous or incorrect

## Constructors and Immutability
- Prefer `const` constructors for classes whose instances can be compile-time constants
- Use initializing formals: `MyClass(this.name, this.age)` — do not declare fields separately
- Use named parameters with `required` for constructors with more than two parameters
- Use `factory` constructors for caching, returning subtypes, or complex initialization

## Collections
- Use collection literals: `[]`, `{}`, `<String, int>{}` — not `List()`, `Map()`
- Use spread operators: `[...list1, ...list2]` — not `list1 + list2` or `addAll`
- Use collection `if` and `for`: `[for (var i in items) if (i.isActive) i.name]`
- Prefer `Iterable` methods (`map`, `where`, `fold`) over manual loops for transformations

## Error Handling
- Throw typed exceptions — define sealed exception hierarchies for domain errors
- Use `on SpecificException catch (e)` — never use bare `catch (e)` without a type
- Use `rethrow` instead of `throw e` when re-throwing — preserves the original stack trace
- Always close resources in `finally` blocks or use try-with-resources patterns

## Async
- Always `await` Futures or return them — never ignore a Future (causes unhandled errors)
- Cancel `StreamSubscription` objects when the listener is no longer needed
- Use `unawaited()` from `dart:async` to explicitly mark intentionally un-awaited Futures

## Documentation
- Write `///` doc comments on all public classes, functions, properties, and named constructors
- Start doc comments with a single-sentence summary in third person: "Returns the user with the given [id]."
- Use `[]` to reference parameters and other identifiers — Dart doc tool creates hyperlinks
- Do not use `/* */` block comments for documentation — only `///`

## Testing
- Use `group()` and `test()` from `package:test` — organize tests by feature or class
- Use `setUp()` and `tearDown()` for test fixtures — prefer `late` fields initialized in setUp
- Use `mocktail` over `mockito` for Dart — no code generation required
- Test Streams with `expectLater` and `emitsInOrder`, `emits`, `emitsError` matchers
- Use `expectAsync1()` to wrap callbacks that must be called during async tests
- Name test files `<source_file>_test.dart` — place in a mirrored `test/` directory structure

## Package Structure
- Export public API from a single barrel file: `lib/my_package.dart`
- Keep implementation files in `lib/src/` — they should not be imported directly by consumers
- Use `show` and `hide` in exports for fine-grained public API control
- Prefer separate library files with imports over `part` / `part of` — use `part` only for code generation

## Static Analysis
- Enable `dart analyze` in CI — treat all warnings as errors
- Use a shared `analysis_options.yaml` — include `package:lints/recommended.yaml` or `package:flutter_lints`
- Add project-specific rules for stricter enforcement: `avoid_dynamic_calls`, `prefer_const_constructors`
- Fix all analyzer warnings before merging — do not suppress without a team-reviewed comment
- Use `// ignore:` comments only with a justification comment alongside — never blanket-ignore
