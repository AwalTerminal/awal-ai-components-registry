# Clojure Build & REPL Commands

## deps.edn (tools.deps)

- `clj -M:dev` — start REPL with dev alias
- `clj -M:test` — run tests (with test runner alias)
- `clj -X:test` — run tests via exec-fn
- `clj -M:dev -m myapp.core` — run main namespace
- `clj -T:build uber` — build uberjar (requires build.clj)
- `clj -M:outdated` — check for outdated dependencies (antq alias)
- `clj -Sdeps '{:deps {nrepl/nrepl {:mvn/version "1.1.0"}}}' -M -m nrepl.cmdline` — start nREPL server

## Leiningen

- `lein repl` — start REPL
- `lein test` — run all tests
- `lein test :only myapp.core-test` — run a specific test namespace
- `lein test :only myapp.core-test/my-test` — run a single test
- `lein run` — run the main function
- `lein uberjar` — build standalone JAR
- `lein deps :tree` — show dependency tree
- `lein clean` — remove build artifacts
- `lein ancient` — check for outdated dependencies

## Testing

- `clj -M:test` — run all tests
- `clj -M:test --focus myapp.core-test` — run specific namespace (kaocha)
- `clj -M:test --watch` — re-run on file changes (kaocha)
- `lein test :only myapp.core-test/my-test` — run single test (Leiningen)

## Linting and Formatting

- `clj-kondo --lint src test` — lint source and test files
- `cljfmt check src/ test/` — check formatting
- `cljfmt fix src/ test/` — auto-format files
- `clj -M:eastwood` — run Eastwood linter (additional checks)

## REPL Workflow

- Connect editor to nREPL (port in `.nrepl-port`)
- `(require '[myapp.core :as core] :reload)` — reload a namespace
- `(clojure.tools.namespace.repl/refresh)` — reload all changed namespaces
- `(clojure.repl/doc fn-name)` — look up documentation
- `(clojure.repl/source fn-name)` — view source of a function

## Dependency Management

- `clj -Stree` — print full dependency tree
- `clj -X:deps mvn-pom` — generate pom.xml from deps.edn
- `clj -X:deps list` — list all resolved dependencies
