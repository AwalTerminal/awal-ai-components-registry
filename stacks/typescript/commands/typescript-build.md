# TypeScript Build & Test

## Type Checking
- `tsc --noEmit` — type-check the entire project without emitting files
- `tsc --noEmit --watch` — type-check in watch mode for development
- `tsc --build` — compile the project (or project references in monorepos)
- `tsc --build --clean` — remove all compiled output

## Testing
- `npx vitest` — run tests once with Vitest
- `npx vitest --watch` — run tests in watch mode
- `npx vitest --coverage` — run tests with coverage report (uses v8 or istanbul)
- `npx vitest run --reporter=verbose` — detailed per-test output
- `npx vitest typecheck` — run type-level tests with expectTypeOf
- `npx jest --passWithNoTests` — run tests with Jest (if using ts-jest)

## Linting and Formatting
- `npx eslint .` — lint all files with ESLint and @typescript-eslint
- `npx eslint . --fix` — lint and auto-fix all fixable issues
- `npx prettier --check .` — check formatting without modifying files
- `npx prettier --write .` — auto-format all files in place
- `npx tsc --noEmit && npx eslint . && npx prettier --check .` — full CI check pipeline

## Bundling
- `npx vite build` — production build with Vite
- `npx esbuild src/index.ts --bundle --outfile=dist/index.js --platform=node` — fast single-file bundle
- `npx tsup src/index.ts --format esm,cjs --dts` — library build with ESM + CJS + declarations

## Package Management
- `npm ci` — clean install from lockfile (CI environments)
- `npm outdated` — check for outdated dependencies
- `npx depcheck` — find unused dependencies
- `npx tsc --showConfig` — print the resolved tsconfig for debugging

## Monorepo (Turborepo / Nx)
- `npx turbo run build` — build all packages in dependency order
- `npx turbo run test --filter=./packages/core` — run tests for a specific package
- `npx nx affected --target=test` — run tests only for changed packages and dependents

## Debugging
- `node --inspect dist/index.js` — start with debugger attached (Chrome DevTools or VS Code)
- `node --enable-source-maps dist/index.js` — enable source maps for stack traces
- `NODE_OPTIONS='--max-old-space-size=4096' npx tsc` — increase heap for large projects
