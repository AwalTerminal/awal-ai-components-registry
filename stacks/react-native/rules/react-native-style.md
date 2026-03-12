# React Native Style Rules

- Use TypeScript with `strict: true` for all components and screens
- Use `eslint` with `@react-native/eslint-config` — fix all warnings
- Use `StyleSheet.create()` for all styles — avoid inline style objects
- Use `FlatList` or `FlashList` for lists — never use `ScrollView` with `.map()`
- Keep components under 150 lines — extract hooks and sub-components when they grow
- Type all navigation route params — use `RootStackParamList` pattern
- Use absolute imports with path aliases (`@/`) — avoid deep relative paths
- Test screens with React Native Testing Library — test behavior, not implementation
