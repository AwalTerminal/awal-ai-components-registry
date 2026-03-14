# TypeScript Style Rules

## Strict Configuration
- Enable `strict: true` in `tsconfig.json` — never disable individual strict checks
- Enable `noUncheckedIndexedAccess` — array and record access returns `T | undefined`
- Enable `verbatimModuleSyntax` — enforces explicit `import type` for type-only imports
- Enable `exactOptionalPropertyTypes` — distinguishes `undefined` from missing properties

## Type Declarations
- Use `interface` for object shapes that may be extended by consumers or across modules
- Use `type` for unions, intersections, mapped types, conditional types, and utility derivations
- Never use `any` — use `unknown` and narrow explicitly with type guards or assertions
- Use `readonly` on properties, arrays, and tuples that must not be mutated after creation
- Prefer `as const` objects or string union types over `enum` — enums have runtime cost and erratic tree-shaking

## Naming Conventions
- Types and interfaces: `PascalCase` — e.g., `UserProfile`, `ApiResponse<T>`
- Type parameters: single uppercase letter or descriptive `PascalCase` with `T` prefix — `T`, `TResult`, `TKey`
- Constants: `UPPER_SNAKE_CASE` for true constants, `camelCase` for derived/computed values
- Boolean variables: prefix with `is`, `has`, `should`, `can` — e.g., `isActive`, `hasPermission`
- Files: `kebab-case.ts` for modules, `PascalCase.tsx` for React components

## Imports
- Use `import type { ... }` for type-only imports — they are erased at compile time
- Use inline type imports when mixing: `import { createUser, type UserInput } from "./users"`
- Order imports: external packages first, then internal modules, then relative imports, then type-only
- Avoid wildcard imports (`import * as`) except for namespace modules like `node:path`
- Never use `require()` in TypeScript — always use ESM `import`

## Functions and Parameters
- Prefer named parameters via object destructuring for functions with more than two parameters
- Use `readonly` parameter types for arrays and objects that should not be mutated by the function
- Use explicit return types on exported functions — rely on inference only for private/local functions
- Use `unknown` in catch blocks and narrow: `catch (err) { if (err instanceof Error) ... }`

## Error Handling
- Use `@ts-expect-error` over `@ts-ignore` — it errors when the suppression becomes unnecessary
- Throw `Error` subclasses — never throw strings, numbers, or plain objects
- Use the Result pattern (`{ ok: true; value: T } | { ok: false; error: E }`) for expected failures
- Reserve `try/catch` for unexpected failures at system boundaries

## Code Organization
- Co-locate types with the module that uses them — avoid a global `types/` directory
- Export public API from barrel files (`index.ts`) — keep internal modules unexported
- Limit files to a single responsibility — split when a file exceeds ~300 lines
- Use path aliases (`@/`) configured in tsconfig and bundler for clean internal imports

## Formatting and Linting
- Use `prettier` for formatting and `eslint` with `@typescript-eslint` for linting — run both in CI
- Fix all ESLint warnings before committing — do not suppress without a code-review-approved comment
- Maximum line length: 100 characters (prettier default or configured)
- Use trailing commas in multiline lists, parameters, and type members

## Testing
- Use `vitest` for new projects — it supports TypeScript natively without a separate compile step
- Use `describe` / `it` blocks with descriptive names that read as sentences
- Use `expectTypeOf` for compile-time type assertions alongside runtime tests
- Use `vi.fn()` for mock functions — type-safe and auto-cleared with `vi.clearAllMocks()`
- Use `Partial<T>` for test fixtures — override only the fields relevant to the test
- Mock at module boundaries (repositories, API clients) — not deep internals
- Aim for 80%+ coverage on business logic — skip coverage mandates on types-only files

## Module System
- Use ESM (`import`/`export`) exclusively — never use `require()` in TypeScript
- Set `"type": "module"` in `package.json` for Node.js ESM projects
- Use `import.meta.url` instead of `__dirname` / `__filename` in ESM
- Use `.mts` / `.cts` extensions to force module type on individual files when needed
- Configure `"moduleResolution": "bundler"` in tsconfig for Vite / esbuild projects

## Documentation
- Write JSDoc on all exported functions, types, and classes — include `@param`, `@returns`, and `@throws`
- Use `@example` blocks in JSDoc for non-obvious APIs
- Document generic constraints: explain what `T extends ...` requires from callers
- Do not duplicate type information in comments — the types are the documentation

## TSConfig Essentials
- Enable `strict: true` — this enables `strictNullChecks`, `strictFunctionTypes`, `noImplicitAny`, and more
- Enable `noUncheckedIndexedAccess` — indexing arrays and records returns `T | undefined`
- Enable `exactOptionalPropertyTypes` — optional properties do not accept explicit `undefined` assignment
- Enable `isolatedModules` — required for esbuild, Vite, and SWC compatibility
- Set `"skipLibCheck": true` — skip type-checking `node_modules` `.d.ts` files for faster builds
- Use `"target": "ES2022"` or later — enables native `using`, `structuredClone`, and modern syntax
