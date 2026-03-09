# Flutter Architecture

## State Management
- Use Riverpod or Bloc for complex state — avoid `setState()` in large widgets
- Keep business logic out of widgets — use providers/cubits/blocs
- Use `AsyncValue` or equivalent for loading/error/data states
- Dispose controllers and subscriptions in `dispose()`

## Widget Structure
- Keep widgets small and focused — extract when a build method exceeds ~50 lines
- Use `const` constructors wherever possible for performance
- Prefer composition over inheritance for widget reuse
- Separate UI widgets from "smart" widgets that manage state

## Navigation
- Use GoRouter or auto_route for declarative routing
- Define routes as constants, not inline strings
- Use typed route parameters, not raw maps

## Platform
- Use `Platform.isIOS` / `Platform.isAndroid` for platform-specific logic
- Keep platform channels in a dedicated service layer
- Test on both iOS and Android before merging

## Performance
- Use `ListView.builder()` for long lists, never `Column` with many children
- Use `RepaintBoundary` for expensive subtrees
- Profile with Flutter DevTools before optimizing
- Avoid rebuilding the entire widget tree — use `Selector` / `select` on providers
