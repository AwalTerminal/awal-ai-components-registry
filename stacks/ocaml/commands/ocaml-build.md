# OCaml Build & Test

Run with dune:
- `dune build` — compile the project
- `dune runtest` — run all tests
- `dune exec bin/main.exe` — build and run the executable
- `dune utop` — open a REPL with project modules loaded
- `dune build @check` — type-check without linking
- `dune clean` — remove build artifacts
- `ocamlformat --check .` — check formatting
- `opam install . --deps-only` — install dependencies
