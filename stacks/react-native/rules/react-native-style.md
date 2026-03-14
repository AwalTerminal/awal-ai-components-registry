# React Native Style Rules

- Use TypeScript with `strict: true` for all components, screens, and hooks
- Use functional components with hooks exclusively -- no class components
- Use `StyleSheet.create()` for all styles -- it validates at creation and enables optimization
- Never use inline style objects in render -- they create new references on every render
- Use `FlatList` or `FlashList` for lists -- never use `ScrollView` with `.map()` for dynamic data
- Keep components under 150 lines -- extract custom hooks and sub-components when they grow
- Use platform-specific files (`*.ios.tsx`, `*.android.tsx`) for platform-divergent behavior
- Use `Platform.select` for small style differences between platforms
- Type all navigation route params -- use `RootStackParamList` declaration merging pattern
- Use absolute imports with path aliases (`@/`) -- avoid deep relative `../../` paths
- Use `eslint` with `@react-native/eslint-config` -- fix all warnings before committing
- Use `React.memo` on list item components that receive stable props
- Avoid anonymous functions in `onPress`, `renderItem` -- extract to `useCallback` or named functions
- Use `react-native-reanimated` for animations -- avoid `Animated` API for new animations
- Test with React Native Testing Library -- test behavior and accessibility, not component internals
- Handle all edge cases for safe areas using `react-native-safe-area-context`
