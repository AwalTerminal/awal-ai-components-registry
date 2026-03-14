# Angular Style Rules

- Use standalone components for all new code -- avoid `NgModule` unless maintaining legacy
- Use `ChangeDetectionStrategy.OnPush` on every component -- signals and immutable data make this safe
- Use `signal()`, `computed()`, and `effect()` for component-level reactive state
- Use `input()`, `input.required()`, and `output()` signal-based APIs for component I/O
- Use `inject()` function instead of constructor injection for cleaner, more flexible code
- Use `@if`, `@for`, `@switch` built-in control flow (Angular 17+) -- avoid `*ngIf`, `*ngFor`
- Always provide `track` in `@for` loops -- use a stable unique identifier, not the index
- Follow Angular naming conventions: `feature-name.component.ts`, `feature-name.service.ts`, `feature-name.pipe.ts`
- Keep templates under 50 lines -- extract presentational sub-components when they grow
- Use `providedIn: 'root'` for singleton services -- avoid manual provider arrays unless scoping
- Use `takeUntilDestroyed()` or `toSignal()` for RxJS subscriptions -- never leave subscriptions unmanaged
- Use `NonNullableFormBuilder` for typed reactive forms -- avoid untyped `FormGroup` constructors
- Run `ng lint` (ESLint with `@angular-eslint`) and fix all warnings before committing
- Run `ng build` before committing to catch AOT compilation errors
- Use lazy-loaded routes with `loadComponent` or `loadChildren` for all feature areas
