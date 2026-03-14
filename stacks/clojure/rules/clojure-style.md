# Clojure Style Rules

## Formatting
- Use `cljfmt` or `zprint` for consistent formatting — run before every commit
- 2-space indentation for all forms
- Align map values when it improves readability
- Keep lines under 100 characters
- Place closing parens on the same line — never on their own line

## Naming
- Namespaces: `kebab-case` matching directory structure (`my-app.core`)
- Functions and locals: `kebab-case` (`calculate-total`, `user-id`)
- Predicates end with `?`: `active?`, `valid-email?`
- Conversion functions use `->`: `map->User`, `str->int`
- Side-effecting functions end with `!`: `save!`, `reset!`
- Private functions: prefer `defn-` over `^:private` metadata
- Constants: `kebab-case` — no SCREAMING_SNAKE in Clojure
- Protocols and records: `PascalCase` (`Renderable`, `HttpClient`)

## Namespaces
- Keep `:require` sorted alphabetically
- Use `:as` aliases consistently across the project: `[clojure.string :as str]`
- Avoid `:refer :all` — use explicit `:refer` or `:as` alias
- One namespace per file, matching the file path exactly
- Group requires: stdlib, external libs, internal namespaces

## Data
- Prefer plain maps over records unless you need protocol implementation or performance
- Use namespaced keywords for spec and cross-namespace data: `:user/email`
- Avoid deeply nested data — flatten when possible
- Use `nil` punning intentionally — `(seq coll)` instead of `(not (empty? coll))`

## Functions
- Keep functions under 20 lines — extract helpers with `letfn` or private `defn-`
- Use `->` for object-first pipelines, `->>` for collection-last pipelines
- Prefer `cond` over nested `if` for multiple branches
- Use multi-arity functions for optional params instead of variadic `& args`
- Always use `recur` for self-recursion — never call the function by name in tail position
- Use `when` over `(if x y nil)` — use `if` only when both branches are meaningful

## Error Handling
- Use `ex-info` with data maps for exceptions: `(throw (ex-info "msg" {:code 404}))`
- Validate at system boundaries (HTTP handlers, CLI entry points), not deep in core logic
- Return data (maps with `:ok`/`:error` keys) instead of throwing when callers need to branch

## Concurrency
- Default to atoms for state — use refs only when multi-ref coordination is required
- Never deref an agent if you need the value immediately — agents are for fire-and-forget
- Use `core.async` channels for event-driven pipelines, not for simple shared state

## REPL Workflow
- Use `comment` blocks for scratch code — they serve as runnable documentation
- Keep `dev/user.clj` for REPL startup helpers (system reset, fixture loading)
- Use `tap>` for debugging instead of `println`

## Documentation
- Write docstrings for all public functions — include param descriptions and return values
- Use `^:deprecated` metadata for functions being phased out
- Avoid `def` inside functions — use `let` for local bindings

## Linting
- Run `clj-kondo --lint src test` before every commit
- Address all warnings — configure `.clj-kondo/config.edn` for project-specific rules
- Enable `:warn-on-reflection` in dev profile to catch missing type hints
