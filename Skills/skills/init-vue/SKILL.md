# Initialize Vue Best Practices

Add Vue 3 + TypeScript best practices. **Follow `~/.copilot/skills/init-conventions/SKILL.md` for standard file handling.**

## Target File

`.github/instructions/vue.instructions.md`

## Path Pattern

`**/*.vue`

## Content

<!-- RULES_START -->
---
applyTo: "**/*.vue"
---

# Vue 3 + TypeScript Rules

### Core Patterns

**Always use `<script setup lang="ts">`** — better perf, cleaner code, superior type inference.

**Prefer `ref()` over `reactive()`** — works with all types, can be reassigned, maintains reactivity.

```typescript
const count = ref(0)  // ref: primitives & replaceable values
const user = ref<User | null>(null)
const form = reactive({ name: '', email: '' })  // reactive: grouped state, never reassign
```

### Reactivity

**Destructuring loses reactivity** — use `toRefs()`: `const { count } = toRefs(reactive({ count: 0 }))`

| `computed()` | `watch()` | `watchEffect()` |
|--------------|-----------|-----------------|
| Derived/cached | Need old value/explicit deps | Auto-track, run immediately |

### Props & Emits

```typescript
interface Props { title: string; count?: number; items?: string[] }

// Vue 3.5+ destructure with defaults
const { title, count = 0, items = [] } = defineProps<Props>()

// Vue 3.4 and below
const props = withDefaults(defineProps<Props>(), { count: 0, items: () => [] })

const emit = defineEmits<{ change: [id: number]; update: [value: string] }>()
```

### Template Refs

```typescript
const input = useTemplateRef<HTMLInputElement>('input')  // Vue 3.5+
const input = ref<HTMLInputElement | null>(null)  // Pre-3.5
const comp = ref<InstanceType<typeof MyComponent> | null>(null)  // Component ref
```

### Composables

Name with `use` prefix. Accept `MaybeRef<T>`. Return object of refs. Always cleanup.

```typescript
export function useFetch<T>(url: MaybeRef<string>) {
  const data = ref<T | null>(null), error = ref<Error | null>(null), isLoading = ref(false)

  const execute = async () => {
    isLoading.value = true
    try { data.value = await fetch(unref(url)).then(r => r.json()) }
    catch (e) { error.value = e instanceof Error ? e : new Error(String(e)) }
    finally { isLoading.value = false }
  }
  return { data, error, isLoading, execute }
}
```

### Lifecycle & Cleanup

```typescript
onMounted(() => {
  window.addEventListener('resize', handler); const id = setInterval(poll, 5000)
  onUnmounted(() => { window.removeEventListener('resize', handler); clearInterval(id) })
})
```

### Pinia

```typescript
export const useUserStore = defineStore('user', () => {
  const user = ref<User | null>(null)
  const isLoggedIn = computed(() => !!user.value)
  async function login(creds: Credentials) { user.value = await api.login(creds) }
  return { user, isLoggedIn, login }
})

const store = useUserStore()
const { user, isLoggedIn } = storeToRefs(store)  // state/getters need storeToRefs
const { login } = store  // actions destructure directly
```

| Pinia Store | Composable |
|-------------|------------|
| Global/shared state, DevTools, SSR | Component-scoped, reusable logic |

### provide/inject

```typescript
const UserKey: InjectionKey<UserContext> = Symbol('User'); provide(UserKey, { user: readonly(user), login }); const ctx = inject(UserKey)!
```

### Generic Components

```vue
<script setup lang="ts" generic="T extends string | number">
defineProps<{ items: T[]; selected: T }>()
defineEmits<{ select: [item: T] }>()
</script>
```

### Performance

```vue
<p v-once>{{ staticMessage }}</p>  <!-- Never updates -->
<div v-for="item in list" :key="item.id" v-memo="[item.id === selected]">  <!-- Selective re-render -->
```

```typescript
const bigList = shallowRef<Item[]>([])  // Large data — must replace on update
bigList.value = [...bigList.value, newItem]
const chart = markRaw(new Chart(canvas, config))  // Non-reactive (charts, maps)
const Modal = defineAsyncComponent(() => import('./Modal.vue'))
```

**Props stability:**
```vue
<Item v-for="item in list" :active-id="activeId" />  <!-- Bad: all update on activeId change -->
<Item v-for="item in list" :active="item.id === activeId" />  <!-- Good: only affected update -->
```

### Vue Router 4

```typescript
declare module 'vue-router' {
  interface RouteMeta { requiresAuth?: boolean }
}

router.beforeEach((to) => {
  if (to.meta.requiresAuth && !isAuth()) return '/login'
})
{ path: '/dash', component: () => import('@/views/Dashboard.vue') }  // Always lazy-load
```

### Testing (Vitest)

```typescript
import { mount } from '@vue/test-utils'
const wrapper = mount(Component, {
  props: { title: 'Test' },
  global: { plugins: [createTestingPinia({ createSpy: vi.fn })] }
})
expect(wrapper.text()).toContain('Test')
await wrapper.find('button').trigger('click'); expect(wrapper.emitted('submit')).toBeTruthy()
```

### Project Structure

`src/` → `components/{base,common}/`, `composables/`, `stores/`, `views/`, `router/`, `services/`, `types/`

### Common Mistakes

- Never destructure reactive/props directly (`toRefs()`), reassign reactive (use `ref()`), use array index as key (use unique id), skip cleanup (always cleanup in `onUnmounted`), mutate props (emit or v-model)
- Never store components in reactive (`markRaw()`), deep watch large objects (watch specific properties), use single-word component names (conflicts with HTML), destructure store state (`storeToRefs()`)

### Quick Reference

| Need | Solution |
|------|----------|
| Reactive primitive | `ref()` |
| Reactive object (won't replace) | `reactive()` |
| Derived state | `computed()` |
| Side effect | `watch()` / `watchEffect()` |
| Destructure reactive | `toRefs()` |
| Global state | Pinia store |
| Local logic | Composable |
| Static / selective re-render | `v-once` / `v-memo` |
| Large data | `shallowRef()` / `markRaw()` |
<!-- RULES_END -->
