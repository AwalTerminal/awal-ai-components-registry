# Node.js Patterns

## Project Setup
- Use `package.json` `"type": "module"` for ES modules
- Use TypeScript for any non-trivial project
- Pin dependency versions in `package-lock.json` — commit it
- Use `engines` field to specify required Node.js version

## Error Handling
- Always handle promise rejections — use `.catch()` or try/catch with await
- Use custom error classes extending `Error` for domain errors
- Use `process.on('unhandledRejection')` as a safety net, not a strategy
- Return meaningful HTTP status codes from API endpoints

## Async Patterns
- Use `async/await` over raw promises or callbacks
- Use `Promise.all()` for concurrent independent operations
- Use `Promise.allSettled()` when some failures are acceptable
- Use `AbortController` for cancellable operations (fetch, timers)

## Security
- Validate and sanitize all user input at the boundary
- Use `helmet` for HTTP security headers in Express
- Never use `eval()` or `new Function()` with user input
- Use parameterized queries — never interpolate SQL strings
- Keep dependencies updated: `npm audit` regularly

## Testing
- Use `vitest` or `jest` for unit tests
- Use `supertest` for HTTP endpoint testing
- Mock external services at the fetch/HTTP layer
- Use `nock` or `msw` for HTTP mocking
