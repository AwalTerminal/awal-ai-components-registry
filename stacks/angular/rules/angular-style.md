# Angular Style Rules

- Use standalone components — avoid `NgModule` unless maintaining legacy code
- Use `ng lint` (ESLint with `@angular-eslint`) and fix all warnings before committing
- Follow Angular naming conventions: `feature-name.component.ts`, `feature-name.service.ts`
- Use `ChangeDetectionStrategy.OnPush` on all components
- Use signals (`signal()`, `computed()`) over RxJS `BehaviorSubject` for component state
- Use `@if`/`@for`/`@switch` control flow over structural directives
- Keep templates under 50 lines — extract sub-components when they grow
- Run `ng test --watch=false` and `ng build` before committing
