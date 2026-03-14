# Java Build & Test

## Maven
- `mvn compile` — compile main sources
- `mvn test` — run unit tests
- `mvn verify` — run unit + integration tests
- `mvn package -DskipTests` — build JAR/WAR without running tests
- `mvn dependency:tree` — show dependency tree for debugging conflicts
- `mvn versions:display-dependency-updates` — check for newer dependency versions
- `mvn spotless:check` — check formatting (with spotless plugin)
- `mvn spotless:apply` — auto-format sources

## Gradle
- `./gradlew build` — compile, test, and package
- `./gradlew test` — run unit tests
- `./gradlew test --tests "com.example.UserServiceTest"` — run a specific test class
- `./gradlew dependencies --configuration runtimeClasspath` — show dependency tree
- `./gradlew spotlessCheck` — check formatting
- `./gradlew spotlessApply` — auto-format sources
- `./gradlew bootRun` — run Spring Boot application (with spring-boot plugin)

## Static Analysis
- `mvn checkstyle:check` / `./gradlew checkstyleMain` — code style checks
- `mvn spotbugs:check` / `./gradlew spotbugsMain` — find bug patterns
- `mvn pmd:check` — PMD static analysis

## Runtime
- `java -jar target/app.jar` — run packaged application
- `java -XX:+UseZGC -Xms512m -Xmx2g -jar app.jar` — run with ZGC and heap limits
- `jcmd <pid> GC.heap_info` — inspect heap of running process
- `jcmd <pid> Thread.print` — dump all threads

## JMH Benchmarks
- `mvn package -pl benchmarks && java -jar benchmarks/target/benchmarks.jar` — build and run benchmarks

## Testing
- `mvn test -pl module-name` — run tests for a specific module
- `mvn test -Dtest="UserServiceTest#shouldReturnUser*"` — run specific test methods
- `mvn verify -Pfailsafe` — run integration tests (with maven-failsafe-plugin)
- `./gradlew test --tests "*.UserServiceTest.shouldReturnUser*"` — run specific test methods in Gradle
- `./gradlew jacocoTestReport` — generate JaCoCo coverage report

## Debugging
- `java -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005 -jar app.jar` — remote debug
- `jstack <pid>` — dump thread stacks of a running process
- `jmap -histo <pid>` — object histogram for memory analysis
