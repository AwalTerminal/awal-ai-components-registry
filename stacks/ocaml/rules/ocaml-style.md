# OCaml Style Rules

- Use `ocamlformat` with a `.ocamlformat` config — run before committing
- Prefer `snake_case` for values and functions, `PascalCase` for module names and types
- Write `.mli` interface files for all library modules — keep internal helpers private
- Avoid mutable `ref` unless performance requires it — prefer immutable bindings
- Use exhaustive pattern matching — avoid wildcard `_` catch-alls on variant types
- Keep functions under 30 lines — extract helpers as local `let` bindings or submodules
- Document public functions with `(** ... *)` ocamldoc comments
- Run `dune build @check` to type-check without linking — catches errors faster
