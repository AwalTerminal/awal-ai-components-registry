# Angular Dev & Build

Run with Angular CLI:
- `ng serve` -- start dev server with live reload
- `ng serve --open` -- start dev server and open browser
- `ng build` -- build for production (AOT compilation)
- `ng build --configuration=development` -- build with development settings
- `ng test` -- run unit tests with Karma/Jest in watch mode
- `ng test --watch=false --code-coverage` -- run tests once with coverage report
- `ng lint` -- lint all files with ESLint (@angular-eslint)
- `ng lint --fix` -- auto-fix lint issues
- `ng generate component features/my-feature` -- scaffold standalone component
- `ng generate service core/services/my-service` -- scaffold injectable service
- `ng generate pipe shared/pipes/my-pipe` -- scaffold pipe
- `ng e2e` -- run E2E tests (Cypress/Playwright)
- `npx prettier --check .` -- check formatting
- `npx prettier --write .` -- auto-format all files
- `npx tsc --noEmit` -- type-check outside Angular compiler
