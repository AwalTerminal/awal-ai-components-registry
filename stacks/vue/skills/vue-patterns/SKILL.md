# Vue Patterns

## Composition API
- Use `<script setup>` for the most concise component syntax
- Use `ref()` for primitives, `reactive()` for objects — access `ref` values with `.value`
- Use `computed()` for derived state — it caches until dependencies change
- Use `watch()` for side effects when reactive data changes
- Use `toRefs()` when destructuring reactive objects to preserve reactivity

## Component Design
- Keep components small — extract when a component exceeds ~100 lines of template + script
- Use `defineProps()` with TypeScript for type-safe props
- Use `defineEmits()` to declare and type component events
- Use `v-model` with `defineModel()` for two-way binding on custom components
- Use `<slot>` for content projection and composable component APIs

## State Management
- Use composables (`use*` functions) for reusable stateful logic
- Use `provide`/`inject` for dependency injection in component trees
- Use Pinia for global application state — define stores with `defineStore`
- Keep store actions thin — delegate complex logic to service functions

## Performance
- Use `v-once` for static content that never changes
- Use `defineAsyncComponent` for lazy-loading heavy components
- Use `v-memo` for expensive list rendering optimizations
- Use `shallowRef`/`shallowReactive` for large objects where deep reactivity is unnecessary

## Project Structure
- Use Nuxt for full-stack applications, Vite for SPAs
- Organize by feature: `src/features/auth/`, `src/features/dashboard/`
- Co-locate composables, components, and types within feature directories
- Use auto-imports (via `unplugin-auto-import`) for Vue APIs and composables
