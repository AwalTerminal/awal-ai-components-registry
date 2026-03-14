# Python Patterns

## Type Hints Mastery

```python
from __future__ import annotations
from typing import TypeVar, Generic, Protocol, TypeAlias, overload

# Union syntax (3.10+)
def greet(name: str | None = None) -> str:
    return f"Hello, {name or 'World'}"

# TypeVar for generic functions
T = TypeVar("T")

def first(items: list[T]) -> T | None:
    return items[0] if items else None

# Generic classes
class Stack(Generic[T]):
    def __init__(self) -> None:
        self._items: list[T] = []

    def push(self, item: T) -> None:
        self._items.append(item)

    def pop(self) -> T:
        return self._items.pop()

# Protocols — structural typing (duck typing with type safety)
class Renderable(Protocol):
    def render(self) -> str: ...

def display(item: Renderable) -> None:
    print(item.render())

# Any class with a render() -> str method satisfies Renderable

# TypeAlias for complex types
JSON: TypeAlias = dict[str, "JSON"] | list["JSON"] | str | int | float | bool | None

# Overloaded signatures
@overload
def parse(raw: str) -> dict[str, str]: ...
@overload
def parse(raw: bytes) -> dict[str, bytes]: ...
def parse(raw: str | bytes) -> dict[str, str] | dict[str, bytes]:
    ...
```

## Dataclasses

```python
from dataclasses import dataclass, field
from typing import ClassVar

@dataclass(frozen=True, slots=True)
class Point:
    x: float
    y: float

    def distance_to(self, other: Point) -> float:
        return ((self.x - other.x) ** 2 + (self.y - other.y) ** 2) ** 0.5

# frozen=True: immutable, hashable — usable as dict keys
# slots=True: faster attribute access, less memory

@dataclass
class Config:
    host: str = "localhost"
    port: int = 8080
    tags: list[str] = field(default_factory=list)  # mutable default
    _max_instances: ClassVar[int] = 10  # class variable, not in __init__

    def __post_init__(self) -> None:
        if self.port < 0 or self.port > 65535:
            raise ValueError(f"Invalid port: {self.port}")
```

## Context Managers

```python
from contextlib import contextmanager, asynccontextmanager
import time

# Class-based
class Timer:
    def __enter__(self) -> Timer:
        self.start = time.perf_counter()
        return self

    def __exit__(self, *exc_info) -> None:
        self.elapsed = time.perf_counter() - self.start

with Timer() as t:
    heavy_computation()
print(f"Took {t.elapsed:.3f}s")

# Generator-based — simpler for common cases
@contextmanager
def temp_directory():
    path = Path(tempfile.mkdtemp())
    try:
        yield path
    finally:
        shutil.rmtree(path)

# Async context manager
@asynccontextmanager
async def db_transaction(pool):
    conn = await pool.acquire()
    try:
        await conn.execute("BEGIN")
        yield conn
        await conn.execute("COMMIT")
    except Exception:
        await conn.execute("ROLLBACK")
        raise
    finally:
        await pool.release(conn)
```

## Generators and Iterators

```python
# Generator — lazy evaluation, memory efficient
def read_chunks(path: str, size: int = 8192):
    with open(path, "rb") as f:
        while chunk := f.read(size):
            yield chunk

# Generator expression vs list comprehension
total = sum(x * x for x in range(1_000_000))  # generator — O(1) memory
items = [x * x for x in range(100)]            # list — when you need indexing

# itertools for composable iteration
from itertools import islice, chain, groupby, batched

# Process in batches (3.12+)
for batch in batched(items, 100):
    process_batch(batch)

# Infinite generators with islice
def fibonacci():
    a, b = 0, 1
    while True:
        yield a
        a, b = b, a + b

first_20 = list(islice(fibonacci(), 20))
```

## Decorators

```python
import functools
import time
from typing import Callable, ParamSpec, TypeVar

P = ParamSpec("P")
R = TypeVar("R")

# Typed decorator that preserves function signature
def retry(max_attempts: int = 3, delay: float = 1.0):
    def decorator(func: Callable[P, R]) -> Callable[P, R]:
        @functools.wraps(func)
        def wrapper(*args: P.args, **kwargs: P.kwargs) -> R:
            last_exc: Exception | None = None
            for attempt in range(max_attempts):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exc = e
                    if attempt < max_attempts - 1:
                        time.sleep(delay * (2 ** attempt))
            raise last_exc  # type: ignore[misc]
        return wrapper
    return decorator

@retry(max_attempts=5, delay=0.5)
def fetch_data(url: str) -> dict:
    ...

# For stateful decorators, use a class with __call__
# or use functools.lru_cache / functools.cache for simple memoization
```

## Descriptors and Metaclasses

Descriptors control attribute access via `__get__`, `__set__`, `__set_name__`.
Use them for reusable validation (e.g., a `Validated` descriptor that enforces
value ranges across multiple attributes).

Metaclasses (`class Meta(type)`) customize class creation. They power ORMs
and framework internals. Rarely needed in application code -- prefer
`__init_subclass__` or class decorators for simpler hooks.

## Concurrency

### Asyncio Patterns

```python
import asyncio

# Gather for concurrent independent tasks
async def fetch_all(urls: list[str]) -> list[str]:
    async with aiohttp.ClientSession() as session:
        tasks = [fetch_one(session, url) for url in urls]
        return await asyncio.gather(*tasks, return_exceptions=True)

# TaskGroup (3.11+) — structured concurrency
async def fetch_all_structured(urls: list[str]) -> list[str]:
    results = []
    async with asyncio.TaskGroup() as tg:
        for url in urls:
            tg.create_task(fetch_one(session, url))
    # If any task raises, all others are cancelled

# Semaphore for rate limiting
async def fetch_with_limit(urls: list[str], max_concurrent: int = 10):
    sem = asyncio.Semaphore(max_concurrent)
    async def limited_fetch(url: str) -> str:
        async with sem:
            return await fetch_one(url)
    return await asyncio.gather(*(limited_fetch(u) for u in urls))

# Async generator
async def stream_events(url: str):
    async with aiohttp.ClientSession() as session:
        async with session.get(url) as resp:
            async for line in resp.content:
                yield json.loads(line)
```

### Threading (GIL Implications)

```python
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor

# Threads — useful for I/O-bound work (GIL released during I/O)
with ThreadPoolExecutor(max_workers=10) as pool:
    futures = [pool.submit(fetch_url, url) for url in urls]
    results = [f.result() for f in futures]

# GIL prevents true parallelism for CPU-bound work in threads
# Use multiprocessing or ProcessPoolExecutor instead:
with ProcessPoolExecutor() as pool:
    results = list(pool.map(cpu_heavy_task, data_chunks))
```

### concurrent.futures

```python
from concurrent.futures import as_completed

with ThreadPoolExecutor(max_workers=5) as executor:
    future_to_url = {executor.submit(fetch, url): url for url in urls}
    for future in as_completed(future_to_url):
        url = future_to_url[future]
        try:
            data = future.result(timeout=30)
        except Exception as exc:
            print(f"{url} failed: {exc}")
```

## Performance

### Profiling

```python
# cProfile — function-level profiling
import cProfile
cProfile.run("main()", "output.prof")
# Analyze: python -m pstats output.prof

# line_profiler — line-level profiling
# Add @profile decorator, run with: kernprof -l -v script.py

# memory_profiler — memory usage per line
# Add @profile decorator, run with: python -m memory_profiler script.py

# timeit for micro-benchmarks
import timeit
timeit.timeit("sum(range(1000))", number=10_000)
```

### Optimization Patterns

```python
# Use dict/set for O(1) lookups instead of list scanning
valid_ids = set(load_valid_ids())  # O(1) lookup
if user_id in valid_ids: ...       # not: if user_id in valid_ids_list

# Local variable access is faster than global/attribute
def process(items):
    local_transform = transform  # bind to local once
    return [local_transform(x) for x in items]

# __slots__ for memory-efficient classes with fixed attributes
class Point:
    __slots__ = ("x", "y")
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

# Use collections for specialized needs
from collections import deque, Counter, defaultdict
queue = deque(maxlen=1000)  # O(1) append/popleft
counts = Counter(words)     # built-in counting
graph = defaultdict(list)   # auto-initialize missing keys
```

### NumPy Vectorization

```python
import numpy as np

# Bad — Python loop
result = []
for x in data:
    result.append(x ** 2 + 2 * x + 1)

# Good — vectorized, 10-100x faster for large arrays
data = np.array(data)
result = data ** 2 + 2 * data + 1

# Boolean indexing instead of filter
mask = data > threshold
filtered = data[mask]
```

## Common Pitfalls

- **Mutable default arguments**: `def f(items=[])` shares one list across calls.
  Use `def f(items: list | None = None)` with `items = items or []`.
- **Late binding closures**: `[lambda: i for i in range(5)]` all return 4.
  Fix: `[lambda i=i: i for i in range(5)]`.
- **Catching too broadly**: `except Exception` silences bugs. Catch specific
  exceptions; re-raise or log unexpected ones.
- **Import cycles**: Module A imports B which imports A. Fix by moving shared
  types to a third module or using late imports inside functions.
- **Not closing resources**: Always use `with` for files, connections, locks.
  Relying on `__del__` is unreliable.
- **String concatenation in loops**: `s += chunk` is O(n^2). Use `"".join(parts)`.
