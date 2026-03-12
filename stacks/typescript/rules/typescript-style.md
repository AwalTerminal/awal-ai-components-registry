# TypeScript Style Rules

- Enable `strict: true` in `tsconfig.json` — never disable individual strict checks
- Use `prettier` and `eslint` with `@typescript-eslint` — fix all warnings before committing
- Prefer `interface` for public API shapes, `type` for unions, intersections, and utilities
- Use `unknown` instead of `any` — narrow types explicitly with type guards
- Use `readonly` on properties and arrays that should not be mutated
- Use `enum` sparingly — prefer `as const` objects or union types
- Export types alongside their implementations — avoid separate type-only files
- Use `@ts-expect-error` over `@ts-ignore` — it errors when the suppression is no longer needed
