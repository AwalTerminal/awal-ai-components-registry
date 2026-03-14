# Elixir Style Rules

## Naming
- Modules: `PascalCase` (`MyApp.Accounts.User`)
- Functions and variables: `snake_case`
- Atoms: `snake_case` (`:ok`, `:not_found`, `:already_exists`)
- Predicate functions: suffix with `?` (`valid?`, `admin?`)
- Unsafe/raising functions: suffix with `!` (`get!`, `insert!`)
- Private functions: use `defp` — no underscore prefix convention
- Module attributes: `@snake_case` (`@max_retries`, `@default_timeout`)

## Formatting
- Use `mix format` — configured via `.formatter.exs`
- 2 spaces for indentation
- Max line length: 98 characters (default formatter setting)
- Use trailing commas in multi-line lists and keyword lists
- Group `use`, `import`, `alias`, `require` at the top of each module in that order

## Functional Style
- Use the pipe operator `|>` for data transformation chains
- Pipe into the first argument — design functions to accept the "subject" as the first parameter
- Use pattern matching in function heads instead of `if/case` inside the body
- Use guard clauses (`when is_binary(x)`, `when x > 0`) for type/value constraints
- Prefer `with` over nested `case` for multi-step fallible operations
- Avoid `unless` with `else` — use `if` instead

## Module Design
- One module per file; filename matches module name in snake_case
- Define a public API at the top, private helpers at the bottom
- Use `@moduledoc` and `@doc` for all public modules and functions
- Use `@spec` type specs on all public functions
- Use behaviours (`@callback`) to define contracts between modules
- Use protocols for polymorphic dispatch on data types

## Error Handling
- Return `{:ok, value}` / `{:error, reason}` tuples for expected failures
- Use `!` variants (`get!`, `insert!`) that raise for callers who want exceptions
- Use `with` to chain multiple fallible operations
- Let processes crash and rely on supervisors for recovery — do not over-rescue
- Use `try/rescue` only for truly unexpected errors or third-party library exceptions

## OTP
- Always use `@impl true` on callback implementations
- Keep GenServer callbacks fast — offload heavy work to `Task`
- Prefer `handle_continue` over `send(self(), ...)` for post-init work
- Name processes via `Registry` for dynamic names, module name for singletons
