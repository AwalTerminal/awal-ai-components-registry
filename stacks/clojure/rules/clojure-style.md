# Clojure Style Rules

- Use `cljfmt` or `zprint` for consistent formatting
- Follow `kebab-case` for function and variable names, `PascalCase` for protocols and records
- Keep functions small — prefer composing small functions over large multi-branch functions
- Use `defn-` for private functions, `def ^:private` for private vars
- Avoid `def` inside functions — use `let` for local bindings
- Write docstrings for all public functions
- Prefer `when` over `(if x y nil)` — use `if` only when both branches are meaningful
- Run `clj-kondo` before committing — fix all warnings
