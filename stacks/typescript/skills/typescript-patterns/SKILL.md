# TypeScript Patterns

## Advanced Type System

### Conditional Types
Use conditional types to create types that depend on other types:
```typescript
type IsArray<T> = T extends unknown[] ? true : false;
type Unwrap<T> = T extends Promise<infer U> ? U : T;

// Distributive conditional types — union members are distributed
type ToArray<T> = T extends unknown ? T[] : never;
type Result = ToArray<string | number>; // string[] | number[]

// Prevent distribution with tuple wrapper
type ToArrayNonDist<T> = [T] extends [unknown] ? T[] : never;
type Result2 = ToArrayNonDist<string | number>; // (string | number)[]
```

### Mapped Types
Transform existing types property by property:
```typescript
type Getters<T> = {
  [K in keyof T as `get${Capitalize<string & K>}`]: () => T[K];
};

type Mutable<T> = { -readonly [K in keyof T]: T[K] };

// Filter keys by value type
type PickByType<T, V> = {
  [K in keyof T as T[K] extends V ? K : never]: T[K];
};

interface User { name: string; age: number; active: boolean }
type StringFields = PickByType<User, string>; // { name: string }
```

### Template Literal Types
Build string types from other types:
```typescript
type EventName<T extends string> = `on${Capitalize<T>}`;
type HTTPMethod = "GET" | "POST" | "PUT" | "DELETE";
type APIRoute = `/${string}`;
type Endpoint = `${Lowercase<HTTPMethod>} ${APIRoute}`;

// Extract parts from string types
type ExtractRouteParams<T extends string> =
  T extends `${string}:${infer Param}/${infer Rest}`
    ? Param | ExtractRouteParams<Rest>
    : T extends `${string}:${infer Param}`
      ? Param
      : never;

type Params = ExtractRouteParams<"/users/:id/posts/:postId">; // "id" | "postId"
```

### Discriminated Unions
Model state machines with exhaustive matching:
```typescript
type AsyncState<T, E = Error> =
  | { status: "idle" }
  | { status: "loading" }
  | { status: "success"; data: T }
  | { status: "error"; error: E };

function renderState<T>(state: AsyncState<T>): string {
  switch (state.status) {
    case "idle": return "Ready";
    case "loading": return "Loading...";
    case "success": return `Data: ${state.data}`;
    case "error": return `Error: ${state.error.message}`;
  }
  // No default needed — TypeScript ensures exhaustiveness
}
```

### Branded Types
Prevent accidental type mixing with structural equivalents:
```typescript
type Brand<T, B extends string> = T & { readonly __brand: B };
type UserId = Brand<string, "UserId">;
type OrderId = Brand<string, "OrderId">;

function getUser(id: UserId): User { /* ... */ }

const userId = "abc" as UserId;
const orderId = "xyz" as OrderId;
getUser(userId);   // OK
getUser(orderId);  // Compile error — OrderId is not UserId

// Validation branding pattern
function parseUserId(input: string): UserId {
  if (!input.startsWith("usr_")) throw new Error("Invalid user ID");
  return input as UserId;
}
```

### The `satisfies` Operator
Validate type conformance while preserving the narrowest inferred type:
```typescript
type ColorMap = Record<string, string | [number, number, number]>;

const colors = {
  red: [255, 0, 0],
  green: "#00ff00",
  blue: [0, 0, 255],
} satisfies ColorMap;

// Type is preserved — colors.red is [number, number, number], not string | [...]
colors.red.map(v => v * 2);   // OK — array methods available
colors.green.toUpperCase();    // OK — string methods available
```

## Error Handling

### Result Pattern
Avoid throwing for expected failures — use typed result unions:
```typescript
type Result<T, E = Error> =
  | { ok: true; value: T }
  | { ok: false; error: E };

function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}
function err<E>(error: E): Result<never, E> {
  return { ok: false, error };
}

async function fetchUser(id: string): Promise<Result<User, "NOT_FOUND" | "NETWORK_ERROR">> {
  try {
    const res = await fetch(`/api/users/${id}`);
    if (res.status === 404) return err("NOT_FOUND");
    return ok(await res.json());
  } catch {
    return err("NETWORK_ERROR");
  }
}

// Caller must handle both cases
const result = await fetchUser("123");
if (!result.ok) {
  // result.error is "NOT_FOUND" | "NETWORK_ERROR" — fully typed
  return;
}
// result.value is User here — narrowed automatically
```

### Custom Error Classes
```typescript
// Extend Error with a code field — always set this.name for stack traces
class AppError extends Error {
  constructor(message: string, public readonly code: string, options?: ErrorOptions) {
    super(message, options); // options.cause for error chaining (ES2022)
    this.name = this.constructor.name;
  }
}
```

## Async Patterns

### Promise.allSettled for Partial Failure
```typescript
async function fetchMultiple(urls: string[]) {
  const results = await Promise.allSettled(urls.map(u => fetch(u)));
  const successes = results
    .filter((r): r is PromiseFulfilledResult<Response> => r.status === "fulfilled")
    .map(r => r.value);
  const failures = results
    .filter((r): r is PromiseRejectedResult => r.status === "rejected")
    .map(r => r.reason);
  return { successes, failures };
}
```

### AbortController for Cancellation
```typescript
function fetchWithTimeout(url: string, timeoutMs: number): Promise<Response> {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  return fetch(url, { signal: controller.signal }).finally(() => clearTimeout(timer));
}

// Chaining abort across operations
class RequestManager {
  private controller = new AbortController();

  async fetch(url: string): Promise<Response> {
    return fetch(url, { signal: this.controller.signal });
  }

  cancelAll(): void {
    this.controller.abort();
    this.controller = new AbortController(); // Reset for new requests
  }
}
```

### Async Iterators and Streams
```typescript
async function* paginate<T>(fetcher: (page: number) => Promise<T[]>): AsyncGenerator<T> {
  let page = 0;
  while (true) {
    const items = await fetcher(page++);
    if (items.length === 0) return;
    yield* items;
  }
}

// Usage
for await (const user of paginate(fetchUsersPage)) {
  processUser(user);
}
```

## Performance Patterns

### Tree-Shaking and Bundle Size
```typescript
// WRONG — imports entire library, defeats tree-shaking
import _ from "lodash";
_.pick(obj, ["a", "b"]);

// RIGHT — import only what you need
import pick from "lodash/pick";
pick(obj, ["a", "b"]);

// Use barrel files carefully — re-exporting everything prevents tree-shaking
// Prefer direct imports for large libraries
```

### Lazy Loading
```typescript
// Dynamic imports for code splitting
const AdminPanel = lazy(() => import("./AdminPanel"));

// Conditional loading based on feature flags
async function loadAnalytics() {
  if (config.analyticsEnabled) {
    const { init } = await import("./analytics");
    init();
  }
}
```

### Type-Only Imports
```typescript
// These are erased at compile time — no runtime cost, no bundle impact
import type { User, Config } from "./types";
import { createUser, type UserInput } from "./users";
```

## Type Narrowing Patterns

### Custom Type Guards
```typescript
function isNonNullable<T>(value: T): value is NonNullable<T> {
  return value !== null && value !== undefined;
}

// Assertion functions — throw instead of returning boolean
function assertDefined<T>(value: T, msg?: string): asserts value is NonNullable<T> {
  if (value === null || value === undefined) {
    throw new Error(msg ?? "Value is null or undefined");
  }
}

// Filter with narrowing
const items: (string | null)[] = ["a", null, "b"];
const valid: string[] = items.filter(isNonNullable);
```

## Common Pitfalls

### Object.keys Returns string[]
```typescript
const config = { host: "localhost", port: 3000 };

// WRONG — key is string, not "host" | "port"
Object.keys(config).forEach(key => {
  config[key]; // Error: Element implicitly has 'any' type
});

// RIGHT — use a typed helper or assertion
function typedKeys<T extends object>(obj: T): (keyof T)[] {
  return Object.keys(obj) as (keyof T)[];
}
typedKeys(config).forEach(key => {
  config[key]; // OK — key is "host" | "port"
});
```

### Array.prototype.includes Narrowing Failure
```typescript
const VALID = ["a", "b", "c"] as const;
type Valid = (typeof VALID)[number]; // "a" | "b" | "c"

// WRONG — TypeScript won't narrow string to Valid
function isValid(s: string): boolean {
  return VALID.includes(s); // Error: Argument of type 'string' is not assignable
}

// RIGHT — widen the array type for the check
function isValid(s: string): s is Valid {
  return (VALID as readonly string[]).includes(s);
}
```

### ESM vs CJS Interop
```typescript
// In ESM, there is no require, __dirname, or __filename
import { fileURLToPath } from "node:url";
import { dirname } from "node:path";

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// In package.json, set "type": "module" for ESM
// Use .mts / .cts extensions to force module type per-file
```

## Node.js vs Browser Considerations

### Environment Detection
```typescript
// Use conditional exports in package.json for dual-environment packages
// package.json: { "exports": { "browser": "./dist/browser.js", "node": "./dist/node.js" } }

// Runtime detection when needed
const isNode = typeof globalThis.process !== "undefined" && globalThis.process.versions?.node;
const isBrowser = typeof globalThis.window !== "undefined";
```

### Web Workers for CPU-Bound Work
```typescript
// Offload expensive computation to a Worker
const worker = new Worker(new URL("./heavy.worker.ts", import.meta.url), { type: "module" });

worker.postMessage({ data: largeArray });
worker.onmessage = (event: MessageEvent<Result>) => {
  console.log("Result:", event.data);
};

// In heavy.worker.ts
self.onmessage = (event: MessageEvent<{ data: number[] }>) => {
  const result = expensiveComputation(event.data);
  self.postMessage(result);
};
```
