# Haskell Build & Test Commands

## Stack

- `stack build` — compile the project
- `stack build --fast` — compile without optimization (faster iteration)
- `stack test` — run all test suites
- `stack test --coverage` — run tests with code coverage report
- `stack test --ta '--match "Auth"'` — run tests matching a pattern
- `stack run` — build and run the executable
- `stack run -- --arg1 value` — run with arguments
- `stack ghci` — REPL with project modules loaded
- `stack clean` — remove build artifacts
- `stack build --file-watch` — rebuild on file changes

## Cabal

- `cabal build all` — compile all targets
- `cabal test all` — run all test suites
- `cabal test --test-show-details=streaming` — show test output in real time
- `cabal run exe:myapp` — build and run a specific executable
- `cabal repl` — REPL with project modules
- `cabal clean` — remove build artifacts
- `cabal update` — update package index

## Linting and Formatting

- `hlint src/ test/` — run linter on source and test files
- `hlint src/ --refactor` — auto-apply safe suggestions
- `ormolu --mode check $(find src -name '*.hs')` — check formatting
- `ormolu --mode inplace $(find src -name '*.hs')` — auto-format all files
- `fourmolu -i src/**/*.hs` — format with fourmolu

## GHC Direct

- `ghc -Wall -Wcompat -O2 Main.hs -o main` — compile with warnings and optimization
- `ghci` — start interactive GHC session
- `runghc Script.hs` — interpret a Haskell script

## Dependency Management

- `stack ls dependencies` — list all dependencies
- `cabal freeze` — lock dependency versions
- `cabal gen-bounds` — generate version bounds for dependencies
- `cabal outdated` — check for outdated dependencies

## Profiling

- `stack build --profile` — build with profiling enabled
- `stack exec -- myapp +RTS -p -RTS` — run with time profiling
- `stack exec -- myapp +RTS -hc -RTS` — heap profiling by cost centre
- `hp2ps -c myapp.hp` — convert heap profile to PostScript
