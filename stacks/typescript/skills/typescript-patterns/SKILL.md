# TypeScript Patterns

## Type System
- Use `interface` for object shapes that may be extended, `type` for unions and intersections
- Use discriminated unions for state machines: `type State = { status: "loading" } | { status: "done"; data: T }`
- Use `as const` for literal types and `satisfies` for type-safe inference without widening
- Prefer `unknown` over `any` — force explicit type narrowing
- Use template literal types for string patterns: `type Route = \`/api/${string}\``

## Error Handling
- Use typed error unions or `Result<T, E>` patterns instead of throwing
- When throwing, throw `Error` subclasses — never throw strings or plain objects
- Use `try/catch` at boundaries (API handlers, event handlers) — not in business logic
- Narrow `unknown` in catch blocks: `if (err instanceof Error)`

## Generics
- Use generic constraints: `<T extends { id: string }>` not unconstrained `<T>`
- Prefer `Record<K, V>` over `{ [key: string]: V }` for mapped types
- Use `Readonly<T>`, `Partial<T>`, `Required<T>` utility types to derive shapes
- Use `infer` in conditional types for extracting nested types
- Keep generic functions simple — if the type signature is hard to read, simplify

## Project Structure
- Use `strict: true` in `tsconfig.json` — enable all strict checks
- Use path aliases (`@/`) for cleaner imports — configure in `tsconfig.json` and bundler
- Co-locate types with the code that uses them — avoid a global `types/` directory
- Export types from barrel files (`index.ts`) for public API surfaces

## Testing
- Use `vitest` or `jest` with `ts-jest` — run tests without a separate compile step
- Test types with `expectTypeOf` or `tsd` for compile-time assertions
- Use `Partial<T>` for test fixtures — override only the fields under test
- Mock external dependencies at module boundaries, not deep internals
