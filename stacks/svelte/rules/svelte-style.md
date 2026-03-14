# Svelte Style Rules

- Use Svelte 5 runes (`$state`, `$derived`, `$effect`, `$props`) -- avoid legacy `let` reactivity and `$:` statements
- Use `<script lang="ts">` with TypeScript in all components
- Use `prettier-plugin-svelte` for consistent formatting across `.svelte` files
- Keep components under 100 lines of template -- extract sub-components when they grow
- Use `$lib/` alias for all imports from `src/lib/` -- avoid relative `../../` paths
- Name component files in `PascalCase.svelte` matching the component name
- Co-locate styles in `<style>` blocks -- they are scoped by default; avoid global CSS unless for design tokens
- Use `svelte-check` to catch type errors, unused CSS, and accessibility warnings
- Place shared reactive state in `.svelte.ts` files using class-based stores with `$state`
- Use `{#each items as item (item.id)}` with a unique key -- never use array index as key
- Use `use:action` directives for reusable DOM behavior (click outside, intersection observer, etc.)
- Keep `$effect` blocks minimal and focused -- one concern per effect, always return cleanup if needed
- Use SvelteKit form actions for mutations -- prefer progressive enhancement over client-only fetch
- Avoid `$effect` for derived state -- use `$derived` or `$derived.by` instead
- Use `+page.server.ts` for data that should never reach the client (secrets, DB queries)
