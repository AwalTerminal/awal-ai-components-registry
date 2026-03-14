# Scala Build & Test

## SBT
- `sbt compile` — compile the project
- `sbt test` — run all tests
- `sbt "testOnly *SuiteName"` — run a specific test suite
- `sbt "testOnly *SuiteName -- -z \"test description\""` — run a specific test
- `sbt run` — run the main class
- `sbt "runMain com.example.SpecificMain"` — run a specific main class
- `sbt clean compile` — clean and recompile
- `sbt assembly` — build a fat JAR (requires sbt-assembly plugin)
- `sbt reload` — reload build definition after changing build.sbt
- `sbt dependencyTree` — show dependency tree (requires sbt-dependency-graph)
- `sbt update` — resolve and download dependencies
- `sbt publishLocal` — publish to local Ivy cache

## Formatting
- `sbt scalafmtCheck` — check formatting without modifying files
- `sbt scalafmtAll` — format all source files
- `sbt scalafmtSbt` — format build.sbt files
- `sbt scalafixAll` — run Scalafix rules

## Testing
- `sbt coverage test` — run tests with coverage (requires sbt-scoverage)
- `sbt coverageReport` — generate coverage report
- `sbt "testQuick"` — run only tests affected by recent changes

## Scala CLI (for scripts and small projects)
- `scala-cli run file.scala` — compile and run a Scala file
- `scala-cli test file.test.scala` — run tests
- `scala-cli fmt .` — format with scalafmt
- `scala-cli repl` — start a Scala REPL
