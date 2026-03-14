# Svelte Patterns

## Reactivity (Svelte 5)

### $state

Use `$state` for all reactive declarations. It replaces `let` reactivity from Svelte 4:

```svelte
<script lang="ts">
  // Primitive state
  let count = $state(0);

  // Object state (deeply reactive)
  let user = $state<User>({ name: '', email: '' });

  // Array state
  let items = $state<Item[]>([]);

  function addItem(item: Item) {
    // Direct mutation works with $state (unlike Svelte 4)
    items.push(item);
  }
</script>

<button onclick={() => count++}>Count: {count}</button>
<input bind:value={user.name} />
```

### $derived

Use `$derived` for computed values. It replaces `$:` reactive statements:

```svelte
<script lang="ts">
  let items = $state<Item[]>([]);
  let filter = $state('');

  // Simple derivation
  let total = $derived(items.length);

  // Complex derivation with $derived.by
  let filtered = $derived.by(() => {
    if (!filter) return items;
    const lower = filter.toLowerCase();
    return items.filter(item =>
      item.name.toLowerCase().includes(lower)
    );
  });

  // Derived from other derived values
  let summary = $derived(`${filtered.length} of ${total} items`);
</script>
```

### $effect

Use `$effect` for side effects. Keep effects minimal and focused:

```svelte
<script lang="ts">
  let searchQuery = $state('');
  let results = $state<Result[]>([]);

  // Auto-tracks dependencies (searchQuery)
  $effect(() => {
    if (searchQuery.length < 3) {
      results = [];
      return;
    }

    const controller = new AbortController();
    fetch(`/api/search?q=${searchQuery}`, { signal: controller.signal })
      .then(r => r.json())
      .then(data => { results = data; })
      .catch(() => {});

    // Cleanup function runs before re-execution and on destroy
    return () => controller.abort();
  });

  // Sync to localStorage
  $effect(() => {
    localStorage.setItem('theme', JSON.stringify(theme));
  });

  // $effect.pre runs before DOM update (rare, for scroll preservation etc.)
  $effect.pre(() => {
    previousScrollHeight = container?.scrollHeight ?? 0;
  });
</script>
```

## Shared Reactive State

Create shared stores in `.svelte.ts` files:

```typescript
// lib/stores/cart.svelte.ts
class CartStore {
  items = $state<CartItem[]>([]);

  total = $derived(
    this.items.reduce((sum, item) => sum + item.price * item.quantity, 0)
  );

  count = $derived(
    this.items.reduce((sum, item) => sum + item.quantity, 0)
  );

  add(product: Product) {
    const existing = this.items.find(i => i.id === product.id);
    if (existing) {
      existing.quantity++;
    } else {
      this.items.push({ ...product, quantity: 1 });
    }
  }

  remove(productId: string) {
    this.items = this.items.filter(i => i.id !== productId);
  }

  clear() {
    this.items = [];
  }
}

export const cart = new CartStore();
```

```svelte
<!-- Usage in components -->
<script lang="ts">
  import { cart } from '$lib/stores/cart.svelte';
</script>

<span>Cart ({cart.count}): ${cart.total.toFixed(2)}</span>
```

## Component Composition

### Snippets and Render Props

```svelte
<!-- Reusable template fragments with {#snippet} -->
<script lang="ts">
  import type { Item } from '$lib/types';
  let { items }: { items: Item[] } = $props();
</script>

{#snippet itemRow(item: Item)}
  <div class="row">
    <span>{item.name}</span>
    <span>${item.price}</span>
  </div>
{/snippet}

{#each items as item (item.id)}
  {@render itemRow(item)}
{/each}
```

### Slots and Children

```svelte
<!-- Card.svelte: composable layout component -->
<script lang="ts">
  import type { Snippet } from 'svelte';

  let {
    children,
    header,
    footer,
  }: {
    children: Snippet;
    header?: Snippet;
    footer?: Snippet;
  } = $props();
</script>

<div class="card">
  {#if header}
    <div class="card-header">{@render header()}</div>
  {/if}
  <div class="card-body">{@render children()}</div>
  {#if footer}
    <div class="card-footer">{@render footer()}</div>
  {/if}
</div>
```

### Actions

Use actions for reusable DOM behavior:

```typescript
// lib/actions/clickOutside.ts
export function clickOutside(node: HTMLElement, callback: () => void) {
  function handleClick(event: MouseEvent) {
    if (!node.contains(event.target as Node)) {
      callback();
    }
  }

  document.addEventListener('click', handleClick, true);

  return {
    destroy() {
      document.removeEventListener('click', handleClick, true);
    },
  };
}
```

```svelte
<script lang="ts">
  import { clickOutside } from '$lib/actions/clickOutside';
  let open = $state(false);
</script>

<div use:clickOutside={() => { open = false; }}>
  {#if open}
    <Dropdown />
  {/if}
</div>
```

## SvelteKit

### Load Functions

```typescript
// src/routes/posts/[slug]/+page.server.ts
import type { PageServerLoad } from './$types';
import { error } from '@sveltejs/kit';

export const load: PageServerLoad = async ({ params, locals }) => {
  const post = await locals.db.post.findUnique({
    where: { slug: params.slug },
  });

  if (!post) error(404, 'Post not found');

  return { post };
};
```

### Form Actions

```typescript
// src/routes/login/+page.server.ts
import type { Actions } from './$types';
import { fail, redirect } from '@sveltejs/kit';

export const actions: Actions = {
  default: async ({ request, cookies }) => {
    const data = await request.formData();
    const email = data.get('email')?.toString();
    const password = data.get('password')?.toString();

    if (!email) return fail(400, { email, missing: true });

    const user = await authenticate(email, password!);
    if (!user) return fail(401, { email, incorrect: true });

    cookies.set('session', user.sessionId, { path: '/', httpOnly: true });
    redirect(303, '/dashboard');
  },
};
```

```svelte
<!-- src/routes/login/+page.svelte -->
<script lang="ts">
  import { enhance } from '$app/forms';
  let { form } = $props();
</script>

<form method="POST" use:enhance>
  <input name="email" value={form?.email ?? ''} />
  {#if form?.missing}<p class="error">Email required</p>{/if}
  {#if form?.incorrect}<p class="error">Invalid credentials</p>{/if}
  <input name="password" type="password" />
  <button>Log in</button>
</form>
```

### Hooks

```typescript
// src/hooks.server.ts
import type { Handle } from '@sveltejs/kit';

export const handle: Handle = async ({ event, resolve }) => {
  const session = event.cookies.get('session');
  if (session) {
    event.locals.user = await getUserFromSession(session);
  }

  const response = await resolve(event);
  response.headers.set('X-Frame-Options', 'DENY');
  return response;
};
```

## Performance

- Use `{#key expression}` to force-destroy and recreate a component when data changes identity
- Avoid unnecessary reactivity: use plain `const` for values that never change
- Lazy-load heavy components with dynamic `import()`
- Use `transition:` and `animate:` directives instead of CSS animations for coordinated motion
- SvelteKit streaming: return nested promises from load functions for progressive rendering

```typescript
// Streaming: outer data loads fast, comments stream in
export const load: PageServerLoad = async ({ params }) => {
  const post = await getPost(params.slug); // awaited immediately
  return {
    post,
    comments: getComments(params.slug), // NOT awaited, streams to client
  };
};
```

## Testing

### Component Tests with Vitest

```typescript
import { render, screen } from '@testing-library/svelte';
import { userEvent } from '@testing-library/user-event';
import Counter from './Counter.svelte';

test('increments count on click', async () => {
  const user = userEvent.setup();
  render(Counter, { props: { initial: 0 } });

  expect(screen.getByText('Count: 0')).toBeInTheDocument();

  await user.click(screen.getByRole('button', { name: 'Increment' }));

  expect(screen.getByText('Count: 1')).toBeInTheDocument();
});
```

### E2E with Playwright

```typescript
import { test, expect } from '@playwright/test';

test('login flow', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@test.com');
  await page.getByLabel('Password').fill('password');
  await page.getByRole('button', { name: 'Log in' }).click();

  await expect(page).toHaveURL('/dashboard');
  await expect(page.getByText('Welcome back')).toBeVisible();
});
```
