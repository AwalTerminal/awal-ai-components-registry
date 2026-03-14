# Vue Style Rules

- Use `<script setup lang="ts">` in all components -- it is the most concise and performant syntax
- Use `eslint-plugin-vue` with `vue3-recommended` config -- fix all warnings before committing
- Name component files in `PascalCase.vue` -- use PascalCase in templates: `<UserCard />`
- Use `defineProps<T>()` with TypeScript interface for props -- avoid runtime validation objects
- Use `defineEmits<T>()` with typed events -- ensure consumers get autocomplete and type checking
- Use `defineModel()` for two-way bindings on custom components instead of manual prop + emit
- Use `ref()` for primitives and reassignable values, `reactive()` for form-like objects
- Never destructure `reactive()` directly -- use `toRefs()` to preserve reactivity
- Use `computed()` for derived state -- never use `watch` to sync one reactive value to another
- Keep templates under 50 lines -- extract sub-components for complex sections
- Use `v-bind` shorthand (`:`) and `v-on` shorthand (`@`) consistently
- Co-locate styles in `<style scoped>` -- use `:deep()` only when styling third-party components
- Use composables (`use*` functions) for reusable logic -- prefer composables over mixins
- Run `vue-tsc --noEmit` for type-checking Vue SFCs before committing
- Use Pinia with `defineStore` and `setup` syntax for global state -- keep stores thin
