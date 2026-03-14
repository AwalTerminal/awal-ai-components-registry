# Kotlin Build & Test

## Gradle (Kotlin DSL)
- `./gradlew build` — compile, run tests, and package
- `./gradlew test` — run all unit tests
- `./gradlew test --tests "com.example.UserServiceTest"` — run a specific test class
- `./gradlew test --tests "*should return user*"` — run tests matching a pattern
- `./gradlew check` — run tests, detekt, and ktlint checks
- `./gradlew clean build` — clean and rebuild from scratch

## Linting and Formatting
- `./gradlew ktlintCheck` — check Kotlin code formatting (with ktlint plugin)
- `./gradlew ktlintFormat` — auto-format Kotlin source files
- `./gradlew detekt` — run detekt static analysis
- `./gradlew detektBaseline` — generate baseline for existing issues

## Running
- `./gradlew run` — run the main application (with application plugin)
- `./gradlew bootRun` — run Spring Boot application
- `kotlin -script script.kts` — run a Kotlin script file

## Dependencies
- `./gradlew dependencies --configuration runtimeClasspath` — print dependency tree
- `./gradlew dependencyUpdates` — check for newer dependency versions (with versions plugin)

## Multiplatform (KMP)
- `./gradlew jvmTest` — run JVM-target tests only
- `./gradlew allTests` — run tests for all targets
- `./gradlew publishToMavenLocal` — publish to local Maven for testing

## Coverage
- `./gradlew koverReport` — generate code coverage report (with Kover plugin)
- `./gradlew koverVerify` — verify coverage meets minimum thresholds

## Debugging
- `./gradlew test --debug-jvm` — start tests with remote debugger on port 5005
- `kotlin -J-agentlib:jdwp=transport=dt_socket,server=y,address=5005 -cp app.jar MainKt` — remote debug

## Spring Boot (Kotlin)
- `./gradlew bootJar` — build executable JAR
- `./gradlew bootBuildImage` — build OCI container image
