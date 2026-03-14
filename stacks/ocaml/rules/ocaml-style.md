# OCaml Style Rules

## Formatting
- Use `ocamlformat` with a `.ocamlformat` config at the project root — run before every commit
- Configure profile in `.ocamlformat`: `profile = default` or `profile = janestreet`
- Keep lines under 90 characters
- Use 2-space indentation

## Naming
- Values and functions: `snake_case` (`parse_config`, `user_id`)
- Types: `snake_case` (`user_record`, `parse_error`)
- Modules: `PascalCase` (`UserService`, `HttpClient`)
- Module types (signatures): `UPPER_SNAKE` or `PascalCase` (`CACHE`, `Comparable`)
- Type variables: `'a`, `'b` for generic, `'key`, `'value` for descriptive

## Types and Modules
- Write `.mli` interface files for all library modules — keep internal helpers private
- Use abstract types in `.mli` to hide implementation details
- Prefer concrete types over objects — OCaml objects are rarely idiomatic
- Annotate type variables in ambiguous positions to help the compiler

## Functions
- Keep functions under 30 lines — extract helpers as local `let` bindings or submodules
- Use `function` keyword for immediate pattern matching on the last argument
- Prefer `|>` pipeline style for left-to-right data transformations
- Use labeled arguments (`~key`) for functions with multiple parameters of the same type
- Use optional arguments (`?timeout`) sparingly — prefer explicit option types for clarity

## Pattern Matching
- Use exhaustive pattern matching — avoid wildcard `_` catch-alls on variant types
- Enable `-w +8` (non-exhaustive matching) in compiler flags
- Use `when` guards only when pattern matching alone cannot express the condition
- Prefer `match` over `if/else` for variant destructuring

## Error Handling
- Use `Result.t` for recoverable errors in business logic — reserve exceptions for truly exceptional cases
- Use `Option.t` for absent values — never return `None` to mean "error"
- Define error types as variants: `type error = Not_found of string | Timeout`
- Use `let*` binding operators for monadic chaining

## Mutability
- Avoid mutable `ref` unless performance requires it — prefer immutable bindings
- Use `Hashtbl` judiciously — consider `Map` for small or functional contexts
- Mark intentional mutation with comments explaining why immutability is insufficient

## Documentation
- Document public functions with `(** ... *)` ocamldoc comments
- Include `@param`, `@return`, `@raise` tags for complex functions
- Write module-level documentation explaining the purpose and usage

## Build and CI
- Run `dune build @check` to type-check without linking — catches errors faster
- Enable `-warn-error +A` in CI to treat all warnings as errors
- Use `dune promote` to accept corrected test output for expect tests
