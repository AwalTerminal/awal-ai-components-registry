# OCaml Patterns

## Type System
- Use algebraic data types (variants) to model domain states exhaustively
- Leverage the module system — use signatures (`.mli`) to hide implementation details
- Use `option` instead of null — pattern match or use `Option.map`/`Option.bind`
- Define record types for structured data — prefer records over tuples for clarity
- Use phantom types or private types to enforce invariants at compile time

## Error Handling
- Use `Result.t` (`Ok`/`Error`) for operations that can fail
- Combine results with `Result.bind` or the `let*` syntax (with binding operators)
- Reserve exceptions for truly exceptional cases — prefer `Result` in business logic
- Use `ppx_deriving` to auto-generate `show` for error types

## Functional Style
- Prefer immutable data — use `ref` only when mutation is clearly needed
- Use `List.map`, `List.filter`, `List.fold_left` over manual recursion
- Use `|>` (pipe) for left-to-right data transformation chains
- Leverage pattern matching with guards for complex branching
- Use `match` exhaustively — avoid wildcard `_` catch-alls unless intentional

## Project Structure
- Use `dune` as the build system with a `dune-project` file at the root
- Organize code into libraries (`lib/`), executables (`bin/`), and tests (`test/`)
- Use `.mli` interface files to define the public API of each module
- Pin dependencies with `opam` lock files for reproducible builds

## Testing
- Use `alcotest` or `OUnit2` for unit tests
- Use `qcheck` for property-based testing
- Test pure functions directly — mock side-effectful modules via functors
- Run tests with `dune runtest`
