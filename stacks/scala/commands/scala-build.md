# Scala Build & Test

Run with sbt:
- `sbt compile` — compile the project
- `sbt test` — run all tests
- `sbt "testOnly *SuiteName"` — run a specific test suite
- `sbt run` — run the main class
- `sbt clean compile` — clean and recompile
- `sbt assembly` — build a fat JAR (requires sbt-assembly plugin)
- `sbt scalafmtCheck` — check formatting without modifying files
- `sbt scalafmtAll` — format all source files
