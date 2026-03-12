# Svelte Patterns

## Reactivity
- Use `$state` rune for reactive state in Svelte 5 — replaces `let` reactivity
- Use `$derived` for computed values that depend on other reactive state
- Use `$effect` for side effects — replaces `$:` reactive statements
- Use `$props()` to declare component props with TypeScript types
- Keep reactive state close to where it's used — avoid lifting state unnecessarily

## Component Design
- Keep components small and focused — extract when a component exceeds ~100 lines
- Use `{#snippet}` blocks for reusable template fragments within a component
- Use slots (`{@render children()}`) for composable component APIs
- Prefer `bind:` directives for two-way binding on form elements
- Use `{#each}` with a unique key for list rendering: `{#each items as item (item.id)}`

## State Management
- Use `$state` in `.svelte.ts` files for shared reactive stores
- Use context API (`setContext`/`getContext`) for dependency injection within component trees
- Keep global state minimal — prefer component-local state and prop drilling
- Use `$effect` to sync state with external systems (localStorage, URL, etc.)

## Performance
- Use `{#key}` blocks to force re-creation of components when data changes
- Avoid unnecessary reactivity — use plain variables for non-reactive data
- Lazy-load routes and heavy components with dynamic `import()`
- Use `transition:` and `animate:` directives for performant animations

## Project Structure
- Use SvelteKit for full-stack applications — `src/routes/` for pages, `src/lib/` for shared code
- Co-locate component styles in `<style>` blocks — styles are scoped by default
- Use `$lib/` alias for imports from `src/lib/`
- Place server-only code in `+page.server.ts` and `+server.ts` files
