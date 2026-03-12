# Clojure Patterns

## Data-Oriented Design
- Use plain maps and vectors as the primary data structures — avoid custom types when a map suffices
- Leverage destructuring in function parameters for cleaner access to map keys
- Prefer `assoc`, `update`, `dissoc` for immutable map transformations
- Use `spec` or `malli` to validate data shapes at system boundaries
- Treat data as the interface — functions in, data out

## Functional Style
- Write pure functions as the default — isolate side effects in clearly marked boundaries
- Use `->` and `->>` threading macros to express transformation pipelines
- Prefer `reduce` with an accumulator over manual recursion
- Use `comp` and `partial` for function composition
- Leverage laziness with `map`, `filter`, `take` — but be aware of holding onto the head

## State Management
- Use atoms for shared, synchronous state — `swap!` and `reset!`
- Use refs with `dosync` only when coordinated multi-ref transactions are needed
- Prefer `component` or `integrant` for system lifecycle management
- Avoid global mutable state — pass dependencies explicitly or use a system map

## REPL-Driven Development
- Develop interactively at the REPL — evaluate forms as you write them
- Use `comment` blocks for scratch code that shouldn't run in production
- Keep namespace declarations clean with explicit `:require` and `:import`
- Use `tap>` and `add-tap` for non-intrusive debugging

## Project Structure
- Follow the `src/[group]/[artifact]/` namespace convention
- Keep `deps.edn` or `project.clj` aliases organized by purpose (`:dev`, `:test`, `:prod`)
- Separate side-effectful namespaces from pure logic namespaces
- Use `test/` mirroring `src/` directory structure
