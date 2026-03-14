# React Patterns

## Hooks Mastery

### Custom Hooks

Extract reusable logic into custom hooks. Every custom hook should do one thing well:

```tsx
// Encapsulate async data fetching with loading/error states
function useAsync<T>(asyncFn: () => Promise<T>, deps: unknown[] = []) {
  const [state, setState] = useState<{
    data: T | null;
    error: Error | null;
    loading: boolean;
  }>({ data: null, error: null, loading: true });

  useEffect(() => {
    let cancelled = false;
    setState((s) => ({ ...s, loading: true }));

    asyncFn()
      .then((data) => {
        if (!cancelled) setState({ data, error: null, loading: false });
      })
      .catch((error) => {
        if (!cancelled) setState({ data: null, error, loading: false });
      });

    return () => {
      cancelled = true;
    };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, deps);

  return state;
}

// Usage
function UserProfile({ userId }: { userId: string }) {
  const { data: user, loading, error } = useAsync(
    () => fetchUser(userId),
    [userId],
  );

  if (loading) return <Skeleton />;
  if (error) return <ErrorBanner message={error.message} />;
  return <ProfileCard user={user!} />;
}
```

### useCallback and useMemo

Use `useCallback` when passing callbacks to memoized children. Use `useMemo` for expensive computations:

```tsx
// useCallback: stabilize reference for memoized child
function TodoList({ todos }: { todos: Todo[] }) {
  const [filter, setFilter] = useState("");

  // Only needed because TodoItem is wrapped in React.memo
  const handleToggle = useCallback((id: string) => {
    toggleTodo(id);
  }, []);

  // useMemo: avoid refiltering on every render
  const filtered = useMemo(
    () => todos.filter((t) => t.title.includes(filter)),
    [todos, filter],
  );

  return (
    <>
      <SearchInput value={filter} onChange={setFilter} />
      {filtered.map((todo) => (
        <TodoItem key={todo.id} todo={todo} onToggle={handleToggle} />
      ))}
    </>
  );
}

const TodoItem = React.memo(function TodoItem({
  todo,
  onToggle,
}: {
  todo: Todo;
  onToggle: (id: string) => void;
}) {
  return (
    <div onClick={() => onToggle(todo.id)}>
      {todo.completed ? "done" : "pending"}: {todo.title}
    </div>
  );
});
```

Do NOT wrap every function in useCallback. Only do it when:
- The callback is passed to a `React.memo` child
- The callback is a dependency of another hook

### useRef Patterns

```tsx
// Persist values across renders without causing re-renders
function useInterval(callback: () => void, delay: number | null) {
  const savedCallback = useRef(callback);

  // Update ref on every render so the interval always calls latest callback
  useEffect(() => {
    savedCallback.current = callback;
  });

  useEffect(() => {
    if (delay === null) return;
    const id = setInterval(() => savedCallback.current(), delay);
    return () => clearInterval(id);
  }, [delay]);
}

// Track previous value
function usePrevious<T>(value: T): T | undefined {
  const ref = useRef<T | undefined>(undefined);
  useEffect(() => {
    ref.current = value;
  });
  return ref.current;
}
```

## Component Composition

### Compound Components

```tsx
// Expose sub-components as properties of a parent
function Select({ children, value, onChange }: SelectProps) {
  return (
    <SelectContext.Provider value={{ value, onChange }}>
      <div role="listbox">{children}</div>
    </SelectContext.Provider>
  );
}

function Option({ value, children }: OptionProps) {
  const ctx = useContext(SelectContext);
  const isSelected = ctx.value === value;
  return (
    <div
      role="option"
      aria-selected={isSelected}
      onClick={() => ctx.onChange(value)}
    >
      {children}
    </div>
  );
}

Select.Option = Option;

// Usage
<Select value={color} onChange={setColor}>
  <Select.Option value="red">Red</Select.Option>
  <Select.Option value="blue">Blue</Select.Option>
</Select>
```

### Render Props vs Hooks

Prefer hooks over render props for new code. Use render props when you need to control rendering from the parent:

```tsx
// Hook approach (preferred for most cases)
function useMousePosition() {
  const [pos, setPos] = useState({ x: 0, y: 0 });
  useEffect(() => {
    const handler = (e: MouseEvent) => setPos({ x: e.clientX, y: e.clientY });
    window.addEventListener("mousemove", handler);
    return () => window.removeEventListener("mousemove", handler);
  }, []);
  return pos;
}

// Render prop approach (when children need the data for rendering)
function Virtualized<T>({
  items,
  rowHeight,
  renderItem,
}: {
  items: T[];
  rowHeight: number;
  renderItem: (item: T, index: number) => ReactNode;
}) {
  const { visibleItems, offsetY } = useVirtualScroll(items, rowHeight);
  return (
    <div style={{ transform: `translateY(${offsetY}px)` }}>
      {visibleItems.map((item, i) => renderItem(item, i))}
    </div>
  );
}
```

## State Management

### useState vs useReducer

Use `useReducer` when state transitions are complex or state values depend on each other:

```tsx
type FormState = {
  values: Record<string, string>;
  errors: Record<string, string>;
  touched: Record<string, boolean>;
  isSubmitting: boolean;
};

type FormAction =
  | { type: "SET_FIELD"; field: string; value: string }
  | { type: "SET_ERROR"; field: string; error: string }
  | { type: "TOUCH"; field: string }
  | { type: "SUBMIT_START" }
  | { type: "SUBMIT_END" };

function formReducer(state: FormState, action: FormAction): FormState {
  switch (action.type) {
    case "SET_FIELD":
      return {
        ...state,
        values: { ...state.values, [action.field]: action.value },
        errors: { ...state.errors, [action.field]: "" },
      };
    case "SET_ERROR":
      return {
        ...state,
        errors: { ...state.errors, [action.field]: action.error },
      };
    case "TOUCH":
      return {
        ...state,
        touched: { ...state.touched, [action.field]: true },
      };
    case "SUBMIT_START":
      return { ...state, isSubmitting: true };
    case "SUBMIT_END":
      return { ...state, isSubmitting: false };
  }
}
```

### External Stores

```tsx
// Zustand: minimal boilerplate, works outside React
import { create } from "zustand";

interface AuthStore {
  user: User | null;
  token: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
}

const useAuthStore = create<AuthStore>((set) => ({
  user: null,
  token: null,
  login: async (email, password) => {
    const { user, token } = await api.login(email, password);
    set({ user, token });
  },
  logout: () => set({ user: null, token: null }),
}));

// Select specific slices to prevent unnecessary re-renders
function UserAvatar() {
  const user = useAuthStore((s) => s.user);
  if (!user) return null;
  return <Avatar src={user.avatarUrl} />;
}
```

## Performance

### Code Splitting with Suspense

```tsx
// Lazy-load routes
const Dashboard = lazy(() => import("./pages/Dashboard"));
const Settings = lazy(() => import("./pages/Settings"));

function App() {
  return (
    <Suspense fallback={<PageSkeleton />}>
      <Routes>
        <Route path="/" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
      </Routes>
    </Suspense>
  );
}
```

### Virtualization

```tsx
import { useVirtualizer } from "@tanstack/react-virtual";

function VirtualList({ items }: { items: Item[] }) {
  const parentRef = useRef<HTMLDivElement>(null);
  const virtualizer = useVirtualizer({
    count: items.length,
    getScrollElement: () => parentRef.current,
    estimateSize: () => 60,
    overscan: 5,
  });

  return (
    <div ref={parentRef} style={{ height: "100vh", overflow: "auto" }}>
      <div style={{ height: virtualizer.getTotalSize(), position: "relative" }}>
        {virtualizer.getVirtualItems().map((row) => (
          <div
            key={row.key}
            style={{
              position: "absolute",
              top: 0,
              transform: `translateY(${row.start}px)`,
              width: "100%",
            }}
          >
            <ItemRow item={items[row.index]} />
          </div>
        ))}
      </div>
    </div>
  );
}
```

## Testing

### React Testing Library

Test behavior, not implementation details. Query by role, label, or text:

```tsx
import { render, screen, waitFor } from "@testing-library/react";
import userEvent from "@testing-library/user-event";

test("login form submits with valid credentials", async () => {
  const user = userEvent.setup();
  const onSubmit = vi.fn();
  render(<LoginForm onSubmit={onSubmit} />);

  await user.type(screen.getByLabelText("Email"), "user@example.com");
  await user.type(screen.getByLabelText("Password"), "secret123");
  await user.click(screen.getByRole("button", { name: "Sign in" }));

  await waitFor(() => {
    expect(onSubmit).toHaveBeenCalledWith({
      email: "user@example.com",
      password: "secret123",
    });
  });
});

test("shows validation error for empty email", async () => {
  const user = userEvent.setup();
  render(<LoginForm onSubmit={vi.fn()} />);

  await user.click(screen.getByRole("button", { name: "Sign in" }));

  expect(screen.getByText("Email is required")).toBeInTheDocument();
});
```

### MSW for API Mocking

```tsx
import { setupServer } from "msw/node";
import { http, HttpResponse } from "msw";

const server = setupServer(
  http.get("/api/user", () => {
    return HttpResponse.json({ id: "1", name: "Alice" });
  }),
  http.post("/api/login", async ({ request }) => {
    const body = await request.json();
    if (body.password === "wrong") {
      return HttpResponse.json({ error: "Invalid" }, { status: 401 });
    }
    return HttpResponse.json({ token: "abc123" });
  }),
);

beforeAll(() => server.listen());
afterEach(() => server.resetHandlers());
afterAll(() => server.close());

test("displays user name after login", async () => {
  render(<App />);
  await waitFor(() => {
    expect(screen.getByText("Alice")).toBeInTheDocument();
  });
});
```

### Accessibility Testing

```tsx
import { axe, toHaveNoViolations } from "jest-axe";

expect.extend(toHaveNoViolations);

test("form has no accessibility violations", async () => {
  const { container } = render(<LoginForm onSubmit={vi.fn()} />);
  const results = await axe(container);
  expect(results).toHaveNoViolations();
});
```
