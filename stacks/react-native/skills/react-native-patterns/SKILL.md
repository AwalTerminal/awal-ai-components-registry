# React Native Patterns

## Component Design
- Use functional components with hooks — avoid class components
- Keep components small — separate presentational components from screen-level containers
- Use `StyleSheet.create()` for styles — it validates and optimizes at creation time
- Use `FlatList` or `FlashList` for long lists — never render lists with `map` in `ScrollView`
- Use platform-specific files (`*.ios.tsx`, `*.android.tsx`) for divergent platform behavior

## Navigation
- Use React Navigation as the routing library — define types for all route params
- Use typed navigation hooks: `useNavigation<StackNavigationProp<RootStack>>()`
- Keep navigation structure in a central `navigation/` directory
- Use deep linking configuration for URL-based navigation
- Prefer stack navigators for flows, tab navigators for top-level sections

## State Management
- Use React Context + `useReducer` for moderate state needs
- Use Zustand or Redux Toolkit for complex global state
- Use React Query / TanStack Query for server state (caching, refetching, pagination)
- Use `AsyncStorage` or `MMKV` for persisted local state
- Keep state as local as possible — lift only when multiple components need it

## Performance
- Use `React.memo` for components that re-render with the same props
- Use `useCallback` and `useMemo` to stabilize references passed to child components
- Avoid inline styles and anonymous functions in render — they cause unnecessary re-renders
- Use `Hermes` engine for faster startup and lower memory usage
- Profile with Flipper or React DevTools — fix components that re-render unnecessarily

## Native Integration
- Use Expo modules when available — fall back to bare React Native only when needed
- Use `react-native-reanimated` for 60fps animations on the UI thread
- Use `expo-image` or `react-native-fast-image` for optimized image loading
- Handle permissions with `expo-permissions` or `react-native-permissions`
