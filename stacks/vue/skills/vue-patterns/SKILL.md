# Vue Patterns

## Composition API Mastery

### Reactivity Fundamentals

```vue
<script setup lang="ts">
import { ref, reactive, computed, watch, watchEffect } from 'vue'

// ref for primitives and values you reassign
const count = ref(0)
const user = ref<User | null>(null)
console.log(count.value) // access with .value in script

// reactive for objects you mutate (never reassign the whole object)
const form = reactive({
  email: '',
  password: '',
  errors: {} as Record<string, string>,
})

// computed: cached, only recalculates when dependencies change
const isValid = computed(() => {
  return form.email.includes('@') && form.password.length >= 8
})

// watch: react to specific source changes
watch(
  () => form.email,
  async (newEmail) => {
    if (newEmail.includes('@')) {
      form.errors.email = ''
      const taken = await checkEmail(newEmail)
      if (taken) form.errors.email = 'Email already in use'
    }
  },
  { debounce: 300 } // Vue 3.5+ built-in debounce
)

// watchEffect: auto-tracks all reactive dependencies
watchEffect(() => {
  document.title = user.value ? `${user.value.name} - App` : 'App'
})
</script>
```

### ref vs reactive Decision Guide

Use `ref` when:
- Holding primitives (string, number, boolean)
- You need to reassign the entire value
- Passing reactive state to composables (refs are trackable across function boundaries)

Use `reactive` when:
- Working with form objects where you mutate individual fields
- You want to avoid `.value` in the template (both work the same in templates)

Never destructure `reactive` objects directly -- use `toRefs`:

```ts
const state = reactive({ x: 0, y: 0 })
const { x, y } = toRefs(state) // preserves reactivity
```

## Composables

Build composables as the primary reuse mechanism. Name them `use*`:

```ts
// composables/useFetch.ts
import { ref, watchEffect, type Ref } from 'vue'

interface UseFetchReturn<T> {
  data: Ref<T | null>
  error: Ref<Error | null>
  loading: Ref<boolean>
  refresh: () => Promise<void>
}

export function useFetch<T>(url: Ref<string> | string): UseFetchReturn<T> {
  const data = ref<T | null>(null) as Ref<T | null>
  const error = ref<Error | null>(null)
  const loading = ref(false)

  async function doFetch() {
    loading.value = true
    error.value = null
    try {
      const response = await fetch(typeof url === 'string' ? url : url.value)
      if (!response.ok) throw new Error(`HTTP ${response.status}`)
      data.value = await response.json()
    } catch (e) {
      error.value = e instanceof Error ? e : new Error(String(e))
    } finally {
      loading.value = false
    }
  }

  watchEffect(() => {
    doFetch()
  })

  return { data, error, loading, refresh: doFetch }
}
```

```vue
<script setup lang="ts">
import { computed } from 'vue'
import { useFetch } from '@/composables/useFetch'

const props = defineProps<{ userId: string }>()
const url = computed(() => `/api/users/${props.userId}`)
const { data: user, loading, error } = useFetch<User>(url)
</script>

<template>
  <LoadingSpinner v-if="loading" />
  <ErrorBanner v-else-if="error" :message="error.message" />
  <UserProfile v-else-if="user" :user="user" />
</template>
```

### Composable Patterns

```ts
// composables/useLocalStorage.ts
export function useLocalStorage<T>(key: string, defaultValue: T) {
  const stored = localStorage.getItem(key)
  const data = ref<T>(stored ? JSON.parse(stored) : defaultValue)

  watch(data, (newVal) => {
    localStorage.setItem(key, JSON.stringify(newVal))
  }, { deep: true })

  return data
}

// composables/useDebounce.ts
export function useDebounce<T>(source: Ref<T>, delay = 300): Ref<T> {
  const debounced = ref(source.value) as Ref<T>
  let timeout: ReturnType<typeof setTimeout>

  watch(source, (val) => {
    clearTimeout(timeout)
    timeout = setTimeout(() => { debounced.value = val }, delay)
  })

  return debounced
}
```

## Provide / Inject

Use for dependency injection across component trees. Always use InjectionKey for type safety:

```ts
// keys.ts
import type { InjectionKey, Ref } from 'vue'

export interface ThemeContext {
  theme: Ref<'light' | 'dark'>
  toggle: () => void
}

export const ThemeKey: InjectionKey<ThemeContext> = Symbol('theme')
```

```vue
<!-- Provider component -->
<script setup lang="ts">
import { provide, ref } from 'vue'
import { ThemeKey, type ThemeContext } from '@/keys'

const theme = ref<'light' | 'dark'>('light')
const toggle = () => {
  theme.value = theme.value === 'light' ? 'dark' : 'light'
}

provide(ThemeKey, { theme, toggle })
</script>
```

```vue
<!-- Consumer (any descendant) -->
<script setup lang="ts">
import { inject } from 'vue'
import { ThemeKey } from '@/keys'

const { theme, toggle } = inject(ThemeKey)!
</script>

<template>
  <button @click="toggle">Current: {{ theme }}</button>
</template>
```

## Nuxt Integration

### useAsyncData and useFetch

```vue
<script setup lang="ts">
// useFetch is a Nuxt composable wrapping useAsyncData + $fetch
const { data: posts, status } = await useFetch('/api/posts', {
  query: { page: 1, limit: 20 },
  transform: (response) => response.data, // shape the response
})

// useAsyncData for custom async logic
const { data: stats } = await useAsyncData('dashboard-stats', () => {
  return Promise.all([
    $fetch('/api/stats/users'),
    $fetch('/api/stats/revenue'),
  ])
})
</script>
```

### Server Routes

```ts
// server/api/posts/[id].get.ts
export default defineEventHandler(async (event) => {
  const id = getRouterParam(event, 'id')
  const post = await db.post.findUnique({ where: { id } })

  if (!post) {
    throw createError({ statusCode: 404, statusMessage: 'Post not found' })
  }

  return post
})
```

### Middleware

```ts
// middleware/auth.ts
export default defineNuxtRouteMiddleware((to) => {
  const { user } = useAuth()

  if (!user.value && to.path !== '/login') {
    return navigateTo('/login')
  }
})
```

```vue
<!-- Apply per-page -->
<script setup lang="ts">
definePageMeta({
  middleware: 'auth',
})
</script>
```

## Performance

### v-once and v-memo

```vue
<template>
  <!-- v-once: render once, never update -->
  <footer v-once>
    <p>{{ appVersion }}</p>
    <LegalLinks />
  </footer>

  <!-- v-memo: skip re-render unless dependencies change -->
  <div v-for="item in list" :key="item.id" v-memo="[item.id, item.selected]">
    <ExpensiveComponent :item="item" />
  </div>
</template>
```

### Dynamic Imports and Keep-Alive

```vue
<script setup lang="ts">
import { defineAsyncComponent } from 'vue'

// Lazy-load heavy component
const HeavyChart = defineAsyncComponent({
  loader: () => import('./HeavyChart.vue'),
  loadingComponent: ChartSkeleton,
  delay: 200,
})
</script>

<template>
  <!-- keep-alive: cache component state when switching tabs -->
  <keep-alive :max="5">
    <component :is="currentTab" />
  </keep-alive>
</template>
```

### shallowRef for Large Objects

```ts
import { shallowRef, triggerRef } from 'vue'

// Only top-level .value assignment triggers updates, not deep mutation
const largeDataset = shallowRef<DataPoint[]>([])

function updateDataset(newData: DataPoint[]) {
  largeDataset.value = newData // triggers reactivity
}

// If you mutate, manually trigger
largeDataset.value.push(newPoint)
triggerRef(largeDataset)
```

## Testing

### Vitest with Vue Test Utils

```ts
import { mount } from '@vue/test-utils'
import { describe, it, expect, vi } from 'vitest'
import TodoList from './TodoList.vue'

describe('TodoList', () => {
  it('adds a new todo on form submit', async () => {
    const wrapper = mount(TodoList)

    await wrapper.find('input').setValue('Buy milk')
    await wrapper.find('form').trigger('submit.prevent')

    expect(wrapper.findAll('[data-testid="todo-item"]')).toHaveLength(1)
    expect(wrapper.text()).toContain('Buy milk')
  })

  it('emits delete event with todo id', async () => {
    const wrapper = mount(TodoList, {
      props: {
        todos: [{ id: '1', text: 'Test', done: false }],
      },
    })

    await wrapper.find('[data-testid="delete-btn"]').trigger('click')

    expect(wrapper.emitted('delete')).toEqual([['1']])
  })
})
```

### Testing Composables

```ts
import { ref, nextTick } from 'vue'
import { useDebounce } from './useDebounce'

it('debounces value updates', async () => {
  vi.useFakeTimers()
  const source = ref('initial')
  const debounced = useDebounce(source, 300)

  expect(debounced.value).toBe('initial')

  source.value = 'updated'
  await nextTick()
  expect(debounced.value).toBe('initial') // not yet

  vi.advanceTimersByTime(300)
  await nextTick()
  expect(debounced.value).toBe('updated') // now

  vi.useRealTimers()
})
```

### Testing with Pinia

```ts
import { setActivePinia, createPinia } from 'pinia'
import { useCartStore } from './cartStore'

beforeEach(() => {
  setActivePinia(createPinia())
})

it('adds item to cart', () => {
  const cart = useCartStore()
  cart.addItem({ id: '1', name: 'Widget', price: 9.99 })

  expect(cart.items).toHaveLength(1)
  expect(cart.total).toBe(9.99)
})
```
