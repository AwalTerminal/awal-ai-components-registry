# Dart Build & Test

## Running
- `dart run` — run the default executable from `bin/`
- `dart run bin/main.dart` — run a specific entry point
- `dart run -DENV=production bin/server.dart` — run with compile-time defines

## Testing
- `dart test` — run all tests in `test/`
- `dart test test/unit/` — run tests in a specific directory
- `dart test --name "should return user"` — run tests matching a name pattern
- `dart test --coverage=coverage` — run tests and generate LCOV coverage data
- `dart test --concurrency=4` — control parallel test execution

## Static Analysis and Formatting
- `dart analyze` — run static analysis (errors, warnings, lints)
- `dart analyze --fatal-infos` — treat info-level diagnostics as failures
- `dart format .` — format all Dart files
- `dart format --set-exit-if-changed .` — check formatting without modifying (for CI)
- `dart fix --apply` — apply automated fixes for lints and deprecations
- `dart fix --dry-run` — preview fixes without applying

## Compiling
- `dart compile exe bin/main.dart -o build/app` — compile to native AOT executable
- `dart compile js lib/app.dart -o build/app.js` — compile to JavaScript
- `dart compile kernel bin/main.dart` — compile to kernel snapshot (faster startup than source)

## Dependencies
- `dart pub get` — install dependencies from pubspec.yaml
- `dart pub upgrade` — upgrade dependencies to latest compatible versions
- `dart pub outdated` — show outdated dependencies
- `dart pub deps` — print dependency tree
- `dart pub publish --dry-run` — validate package before publishing

## Code Generation
- `dart run build_runner build` — run code generation (json_serializable, freezed, etc.)
- `dart run build_runner build --delete-conflicting-outputs` — regenerate and overwrite stale outputs
- `dart run build_runner watch` — watch for changes and regenerate automatically

## Documentation
- `dart doc` — generate API documentation from doc comments
