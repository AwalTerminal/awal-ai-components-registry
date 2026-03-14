# Performance Optimization

Analyze code for performance improvements using a profiling-first methodology. Never suggest an optimization without first identifying the bottleneck, quantifying its impact, and analyzing tradeoffs. Premature optimization without measurement is a rejected output.

## Approach

```
Measure --> Identify Bottleneck --> Categorize --> Propose Fix --> Predict Impact --> Verify
```

**Cardinal rule:** If you cannot identify a concrete bottleneck with evidence, report "no actionable optimizations found" rather than suggesting speculative changes.

---

## Optimization Categories

### Category 1: Algorithmic (Big-O)

Reduce the asymptotic complexity of hot paths.

**What to look for:**
- Nested loops over the same data (O(n^2) or worse)
- Repeated linear searches that could use a hash map (O(n) -> O(1) lookup)
- Sorting when only min/max is needed (O(n log n) -> O(n))
- Recomputing values that could be memoized
- Recursive solutions without memoization (exponential -> polynomial)

**Anti-patterns:**
- [ ] Linear search in a loop (`for x in list: if x in other_list`)
- [ ] Concatenating strings in a loop (O(n^2) total allocation)
- [ ] Sorting to find top-k (use a heap instead)
- [ ] Building a result by repeated append + copy
- [ ] Cartesian product when a join/index would suffice
- [ ] Recursive Fibonacci without cache (classic but still shows up)

**Output format for algorithmic fixes:**
```
**Bottleneck:** [function/block] at [location]
**Current complexity:** O(n^2) where n = [description]
**Proposed complexity:** O(n log n) / O(n) / O(1)
**Technique:** [hash map, sorting, two-pointer, memoization, etc.]
**Before:**
  [code snippet -- minimal, showing the hot path]
**After:**
  [code snippet -- the optimized version]
**Estimated speedup:** ~Nx for typical input size of [N]
**Tradeoff:** [additional memory, code complexity, etc.]
```

### Category 2: I/O

Reduce time spent waiting on disk, network, or IPC.

**What to look for:**
- Sequential I/O that could be parallelized or batched
- N+1 query patterns (loop issuing one query per item)
- Unbuffered reads/writes
- Synchronous I/O on the main/UI thread
- Missing connection pooling
- Redundant round-trips (fetching data already available locally)

**Anti-patterns:**
- [ ] `for item in items: db.query(item.id)` (N+1)
- [ ] Reading an entire file to extract one field
- [ ] `fetch()` in a loop without `Promise.all` / `join!` / `gather`
- [ ] Opening/closing connections per request instead of pooling
- [ ] Logging synchronously to disk in a hot path
- [ ] No timeout on external calls (hangs under failure)

**Output format for I/O fixes:**
```
**Bottleneck:** [N+1 queries / sequential fetches / unbuffered writes] at [location]
**Current behavior:** N round-trips for N items, ~Xms each = ~Xms total
**Proposed behavior:** 1 batch query / parallel fetch / buffered write
**Before:**
  [code snippet]
**After:**
  [code snippet]
**Estimated speedup:** ~Xms -> ~Xms (N items)
**Tradeoff:** [batch size limits, error handling complexity, memory for buffering]
```

### Category 3: Memory

Reduce allocation pressure, peak memory, or GC overhead.

**What to look for:**
- Allocations inside tight loops
- Large intermediate collections that could be streamed
- Retained references preventing garbage collection (leaks)
- Copying data that could be passed by reference/slice
- Unbounded caches or buffers

**Anti-patterns:**
- [ ] Creating new objects/closures per iteration in a hot loop
- [ ] Collecting an iterator into a Vec/List only to iterate it again
- [ ] Cloning/copying where a borrow/reference suffices
- [ ] Growing a dynamic array without pre-allocating known capacity
- [ ] Holding references to large objects longer than needed
- [ ] String formatting in a loop (allocates per iteration)

**Output format for memory fixes:**
```
**Bottleneck:** [excessive allocation / memory leak / large intermediate] at [location]
**Current allocation:** ~X MB for typical input, ~Y allocations/sec
**Proposed allocation:** ~X MB, ~Y allocations/sec
**Technique:** [pre-allocation, streaming, arena, object pool, borrow]
**Before:**
  [code snippet]
**After:**
  [code snippet]
**Estimated impact:** ~X% reduction in peak memory / ~X% reduction in GC pauses
**Tradeoff:** [code complexity, lifetime management, API changes]
```

### Category 4: Concurrency

Exploit parallelism or reduce contention.

**What to look for:**
- CPU-bound work on the main thread
- Sequential processing of independent items
- Lock contention (mutex held across I/O or long computation)
- Thread-per-request without pooling
- Shared mutable state requiring synchronization

**Anti-patterns:**
- [ ] Processing items sequentially when they have no dependencies
- [ ] Holding a lock while doing I/O
- [ ] Spawning unbounded threads/tasks (no backpressure)
- [ ] Busy-waiting or spin locks in application code
- [ ] Using a single global lock when fine-grained locking is possible
- [ ] Blocking an async runtime with synchronous calls

**Output format for concurrency fixes:**
```
**Bottleneck:** [sequential processing / lock contention / main thread block] at [location]
**Current throughput:** ~X items/sec on 1 core
**Proposed throughput:** ~X items/sec on N cores
**Technique:** [parallel map, work stealing, lock-free, channel, async]
**Before:**
  [code snippet]
**After:**
  [code snippet]
**Estimated speedup:** ~Nx on M-core machine
**Tradeoff:** [complexity, ordering guarantees, error propagation, debugging difficulty]
```

### Category 5: Caching

Avoid redundant computation or data fetching.

**What to look for:**
- Pure functions called repeatedly with same arguments
- Database queries for rarely-changing data
- Expensive transformations of immutable inputs
- HTTP responses without cache headers
- Recomputing derived state on every access

**Anti-patterns:**
- [ ] Computing the same derived value on every render/request
- [ ] Cache without TTL or eviction (unbounded memory growth)
- [ ] Cache without invalidation strategy (serving stale data)
- [ ] Caching mutable objects (aliasing bugs)
- [ ] Cache key that doesn't capture all inputs (collision)
- [ ] Caching cheap operations (overhead > savings)

**Output format for caching fixes:**
```
**Bottleneck:** [repeated computation / redundant fetch] at [location]
**Call frequency:** ~X times per [second/request/render]
**Computation cost:** ~Xms per call
**Cache strategy:** [memoize, LRU, TTL, write-through, computed/lazy]
**Invalidation:** [on mutation X / after TTL / on event Y]
**Before:**
  [code snippet]
**After:**
  [code snippet]
**Estimated speedup:** ~Xms saved per [unit], ~X% hit rate expected
**Tradeoff:** [memory for cache, staleness window, invalidation complexity]
```

---

## Optimization Decision Tree

Use this to prioritize which category to investigate first:

```
Is the program slow?
├── Measure: where is time spent?
│   ├── Waiting on I/O (network/disk)?
│   │   └── Category 2: I/O optimization
│   ├── CPU-bound in one function?
│   │   ├── Is the algorithm suboptimal?
│   │   │   └── Category 1: Algorithmic
│   │   ├── Is it called too often with same inputs?
│   │   │   └── Category 5: Caching
│   │   └── Can work be parallelized?
│   │       └── Category 4: Concurrency
│   └── GC pauses or high memory?
│       └── Category 3: Memory
└── Not measurably slow?
    └── Report: no actionable optimization found.
```

---

## Measurement Methodology

### Before proposing any optimization:

1. **Identify the hot path.** Use profiling data, flame graphs, or static analysis to determine where time is actually spent. If no profiler is available, analyze call frequency and per-call cost.

2. **Quantify current performance.** Establish a baseline:
   ```
   Metric: [latency / throughput / memory / CPU%]
   Value: [measured or estimated from code analysis]
   Input size: [N = specific value]
   Environment: [hardware/runtime context]
   ```

3. **Set a target.** What would "good enough" look like?
   ```
   Target: [Xms latency / X req/sec / X MB peak memory]
   Justification: [user-facing SLA / resource budget / comparison to similar systems]
   ```

4. **After proposing the fix**, predict the new performance:
   ```
   Expected: [new metric value]
   Confidence: [high -- algorithmic proof / medium -- estimated / low -- speculative]
   Verification: [how to confirm -- benchmark command, profiler check, load test]
   ```

---

## Output Format

```markdown
# Performance Analysis: [scope]

## Profile Summary
[Where time/memory is spent, ranked by impact]

## Findings

### Finding 1: [short description]
[Full output using the category-specific format above]

### Finding 2: [short description]
[Full output using the category-specific format above]

## Priority Order
1. [Finding X] -- estimated Xms / X% improvement, low risk
2. [Finding Y] -- estimated Xms / X% improvement, moderate risk
3. [Finding Z] -- estimated Xms / X% improvement, high risk

## Not Optimized (and why)
- [Thing that looks slow but isn't on the hot path]
- [Thing that's already optimal for the use case]

## Verification Plan
- [ ] Benchmark [specific scenario] before and after
- [ ] Monitor [metric] in staging for [duration]
- [ ] Load test at [X] concurrent [requests/users]
```

---

## Rules

1. **Profiling first.** Never lead with "here are some optimizations." Lead with "here is where time is spent."
2. **One fix per finding.** Do not bundle multiple optimizations into a single suggestion. Each must be independently evaluable.
3. **Before/after required.** Every suggestion must show both the current code and the proposed change.
4. **Quantify or qualify.** Provide estimated speedup. If you cannot estimate, state your confidence level and why.
5. **Tradeoffs are mandatory.** Every optimization trades something. Name it explicitly. If there is no tradeoff, say "none identified" -- do not omit the section.
6. **Do not optimize dead code.** If a function is called once at startup, it is not a bottleneck. Say so and move on.
7. **Readability tax.** If an optimization makes code significantly harder to understand, flag it and let the caller decide. The default recommendation should be "keep it readable."
