# OCaml Build & Test Commands

## Dune (Build System)

- `dune build` — compile the entire project
- `dune build @check` — type-check without linking (faster feedback)
- `dune runtest` — run all tests
- `dune runtest -f` — force re-run all tests
- `dune exec bin/main.exe` — build and run the executable
- `dune exec bin/main.exe -- --arg1 value` — run with arguments
- `dune utop` — open a REPL with project modules loaded
- `dune clean` — remove build artifacts
- `dune build -w` — rebuild on file changes (watch mode)
- `dune promote` — accept corrected test output (expect tests)

## opam (Package Manager)

- `opam install . --deps-only` — install project dependencies
- `opam install . --deps-only --with-test` — include test dependencies
- `opam switch create . ocaml-base-compiler.5.1.0` — create local switch with OCaml 5
- `opam update` — update package index
- `opam list --installed` — list installed packages
- `opam pin add mylib .` — pin local development version

## Formatting and Linting

- `ocamlformat --check .` — check formatting without modifying
- `ocamlformat -i src/*.ml src/*.mli` — auto-format source files
- `dune build @fmt` — check formatting via dune
- `dune promote` — apply formatting fixes from dune fmt

## Testing

- `dune runtest` — run all tests
- `dune exec test/test_main.exe` — run a specific test binary
- `dune runtest --force` — re-run even if nothing changed
- `dune build @runtest --auto-promote` — run and accept expect test changes

## Profiling and Debugging

- `dune build --instrument-with landmarks` — build with Landmarks profiler
- `OCAML_LANDMARKS=auto dune exec bin/main.exe` — run with profiling
- `ocamldebug _build/default/bin/main.bc` — bytecode debugger
- `OCAMLRUNPARAM="v=0x01" dune exec bin/main.exe` — run with GC stats

## Documentation

- `dune build @doc` — generate odoc documentation
- `open _build/default/_doc/_html/index.html` — view generated docs
