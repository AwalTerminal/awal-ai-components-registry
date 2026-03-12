# Angular Patterns

## Signals and Reactivity
- Use `signal()` for reactive state — prefer signals over RxJS for component-level state
- Use `computed()` for derived values from signals
- Use `effect()` for side effects triggered by signal changes
- Use `input()` and `output()` signal-based APIs for component communication
- Use `toSignal()` to bridge RxJS observables into the signal system

## Component Design
- Use standalone components — avoid `NgModule` for new components
- Keep components focused — extract presentational and container components
- Use `@if`, `@for`, `@switch` control flow syntax (Angular 17+) over `*ngIf`, `*ngFor`
- Use `ChangeDetectionStrategy.OnPush` for better performance
- Use content projection (`<ng-content>`) for flexible component composition

## Services and DI
- Use `providedIn: 'root'` for singleton services — avoid manual provider arrays
- Use `inject()` function over constructor injection for cleaner syntax
- Use `HttpClient` with typed responses — define interfaces for API payloads
- Keep services stateless when possible — use signals or stores for state

## RxJS
- Use RxJS for async streams (HTTP, WebSocket, complex event sequences)
- Always unsubscribe — use `takeUntilDestroyed()` or `async` pipe
- Use `switchMap` for HTTP requests triggered by user input
- Avoid nested subscribes — use `concatMap`, `mergeMap`, or `switchMap` instead

## Project Structure
- Organize by feature: `src/app/features/auth/`, `src/app/features/dashboard/`
- Use lazy-loaded routes for feature modules
- Place shared components, pipes, and directives in `src/app/shared/`
- Use `environment.ts` files for configuration — never hardcode API URLs
