# Vue Style Rules

- Use `<script setup>` with TypeScript in all components
- Use `eslint-plugin-vue` with the `vue3-recommended` config — fix all warnings
- Use `PascalCase` for component file names and tag usage in templates
- Use `defineProps()` with TypeScript types — avoid runtime prop validation objects
- Keep templates readable — extract complex logic into `computed()` or methods
- Use `v-bind` shorthand (`:`) and `v-on` shorthand (`@`) consistently
- Co-locate styles in `<style scoped>` — avoid global styles unless for design tokens
- Run `vue-tsc --noEmit` for type-checking Vue SFCs before committing
