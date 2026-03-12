# Svelte Style Rules

- Use `prettier-plugin-svelte` for consistent formatting
- Use Svelte 5 runes (`$state`, `$derived`, `$effect`) — avoid legacy `$:` reactive statements
- Keep components under 100 lines — extract sub-components when they grow
- Use TypeScript in all components: `<script lang="ts">`
- Use `$lib/` alias for all imports from `src/lib/` — avoid relative `../../` paths
- Co-locate styles in `<style>` — avoid global CSS unless defining design tokens
- Use `svelte-check` to catch type errors and accessibility warnings
- Name component files in `PascalCase.svelte` — match the component name
