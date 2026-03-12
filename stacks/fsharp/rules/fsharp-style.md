# F# Style Rules

- Use `fantomas` for consistent formatting — configure `.editorconfig` or `fantomas-config`
- Follow `camelCase` for functions and values, `PascalCase` for types, modules, and namespaces
- Prefer discriminated unions over class hierarchies for domain modeling
- Avoid `mutable` in domain logic — use immutable records and copy-and-update expressions
- Keep the `|>` pipeline readable — one transformation per line for chains over 3 steps
- Use explicit type annotations on public API functions
- Add XML doc comments (`///`) to public types and functions
- Order files in `.fsproj` from foundational types to high-level orchestration
