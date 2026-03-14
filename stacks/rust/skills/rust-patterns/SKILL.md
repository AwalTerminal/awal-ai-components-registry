# Rust Patterns

## Ownership, Borrowing, and Lifetimes

Ownership is Rust's core innovation. Every value has exactly one owner;
when the owner goes out of scope, the value is dropped.

```rust
fn take_ownership(s: String) {
    println!("{s}");
} // s is dropped here

let name = String::from("Alice");
take_ownership(name);
// name is no longer valid here — compile error if used
```

Borrowing lets you reference data without taking ownership:

```rust
fn print_len(s: &str) {  // immutable borrow
    println!("length: {}", s.len());
}

fn append_bang(s: &mut String) {  // mutable borrow — exclusive
    s.push('!');
}

let mut greeting = String::from("hello");
print_len(&greeting);       // shared borrow — any number allowed
append_bang(&mut greeting);  // exclusive borrow — no other refs allowed
```

Lifetimes make borrow durations explicit when the compiler cannot infer them:

```rust
// The returned reference lives as long as the shorter of a and b
fn longest<'a>(a: &'a str, b: &'a str) -> &'a str {
    if a.len() >= b.len() { a } else { b }
}

// Struct holding a reference must declare the lifetime
struct Excerpt<'a> {
    text: &'a str,
}
```

Use `Cow<'_, str>` when a function might or might not need to allocate:

```rust
use std::borrow::Cow;

fn normalize(input: &str) -> Cow<'_, str> {
    if input.contains('\t') {
        Cow::Owned(input.replace('\t', "    "))
    } else {
        Cow::Borrowed(input)
    }
}
```

## Error Handling

```rust
// Library errors — use thiserror for derive macros
use thiserror::Error;

#[derive(Error, Debug)]
pub enum ParseError {
    #[error("invalid header at byte {offset}")]
    InvalidHeader { offset: usize },
    #[error("unsupported version: {0}")]
    UnsupportedVersion(u8),
    #[error(transparent)]
    Io(#[from] std::io::Error),
}

// Application errors — use anyhow for ergonomic context
use anyhow::{Context, Result};

fn load_config(path: &Path) -> Result<Config> {
    let text = std::fs::read_to_string(path)
        .with_context(|| format!("failed to read {}", path.display()))?;
    let config: Config = toml::from_str(&text)
        .context("invalid TOML in config")?;
    Ok(config)
}
```

Pattern: convert between error types with `?` and `From` impls.
Never use `.unwrap()` in library code. Use `.expect("reason")` only when
failure is a bug (invariant violation).

## Trait System

```rust
// Define behavior contracts
trait Summary {
    fn summarize(&self) -> String;

    // Default implementation
    fn preview(&self) -> String {
        let s = self.summarize();
        if s.len() > 100 { format!("{}...", &s[..97]) } else { s }
    }
}

// Blanket implementations
impl<T: Display> Summary for T {
    fn summarize(&self) -> String {
        self.to_string()
    }
}

// Trait objects for heterogeneous collections
fn log_all(items: &[&dyn Summary]) {
    for item in items {
        println!("{}", item.summarize());
    }
}

// impl Trait for static dispatch (zero cost)
fn log_item(item: &impl Summary) {
    println!("{}", item.summarize());
}
```

Use `impl Trait` in argument position for flexibility, concrete or `impl Trait`
in return position for zero-cost abstraction. Use `dyn Trait` only when you
need heterogeneous collections or runtime polymorphism.

## Concurrency

### Send and Sync

- `Send`: safe to transfer ownership to another thread
- `Sync`: safe to share references (`&T`) across threads
- Most types are automatically `Send + Sync`; raw pointers are not
- `Rc<T>` is neither `Send` nor `Sync`; use `Arc<T>` for shared ownership across threads

### Tokio Patterns

```rust
use tokio::sync::{mpsc, Mutex};

// Spawn concurrent tasks
async fn fetch_all(urls: Vec<String>) -> Vec<String> {
    let mut handles = Vec::new();
    for url in urls {
        handles.push(tokio::spawn(async move {
            reqwest::get(&url).await?.text().await
        }));
    }
    let mut results = Vec::new();
    for handle in handles {
        if let Ok(Ok(body)) = handle.await {
            results.push(body);
        }
    }
    results
}

// Channel-based actor pattern
struct DbActor {
    receiver: mpsc::Receiver<DbCommand>,
}

enum DbCommand {
    Get { key: String, reply: oneshot::Sender<Option<String>> },
    Set { key: String, value: String },
}

impl DbActor {
    async fn run(mut self) {
        while let Some(cmd) = self.receiver.recv().await {
            match cmd {
                DbCommand::Get { key, reply } => {
                    let _ = reply.send(self.db.get(&key).cloned());
                }
                DbCommand::Set { key, value } => {
                    self.db.insert(key, value);
                }
            }
        }
    }
}
```

### Rayon for CPU-bound Work

```rust
use rayon::prelude::*;

let sum: u64 = (0..1_000_000u64)
    .into_par_iter()
    .filter(|n| is_prime(*n))
    .sum();
```

### Atomics and Lock-free Patterns

```rust
use std::sync::atomic::{AtomicU64, Ordering};

static REQUEST_COUNT: AtomicU64 = AtomicU64::new(0);

fn handle_request() {
    REQUEST_COUNT.fetch_add(1, Ordering::Relaxed);
}
```

## Unsafe Guidelines

Use `unsafe` only when the safe API cannot express what you need:

```rust
// Document the safety invariant as a comment
// SAFETY: `ptr` was allocated by Vec and len <= capacity
unsafe {
    std::ptr::copy_nonoverlapping(src, dst, len);
}
```

Rules:
- Minimize the `unsafe` block to the smallest possible scope
- Add `// SAFETY:` comments explaining why the invariants hold
- Wrap unsafe operations in safe abstractions with enforced preconditions
- Never transmute between types unless their layouts are guaranteed compatible
- Use `#[repr(C)]` or `#[repr(transparent)]` when layout matters

## Macro Patterns

```rust
// Declarative macros for repetitive patterns
macro_rules! impl_from {
    ($($variant:ident => $type:ty),+ $(,)?) => {
        $(
            impl From<$type> for Error {
                fn from(e: $type) -> Self {
                    Error::$variant(e)
                }
            }
        )+
    };
}

impl_from! {
    Io => std::io::Error,
    Parse => serde_json::Error,
}
```

Prefer declarative macros (`macro_rules!`) for simple cases.
Use proc macros (`#[derive(...)]`, attribute macros) for complex code generation.

## Performance

### Iterator Optimization

```rust
// Iterators compile to the same code as hand-written loops
let total: i64 = data.iter()
    .filter(|item| item.is_active())
    .map(|item| item.score as i64)
    .sum();

// Avoid collect-then-iterate — chain iterators instead
// Bad: let v: Vec<_> = x.iter().filter(...).collect(); v.iter().map(...)
// Good: x.iter().filter(...).map(...)
```

### Allocation Patterns

```rust
// Pre-allocate when size is known
let mut buf = Vec::with_capacity(1024);
let mut map = HashMap::with_capacity(expected_entries);

// Reuse allocations across iterations
let mut line = String::new();
for _ in 0..n {
    line.clear();  // reuses the buffer
    reader.read_line(&mut line)?;
}

// Use SmallVec for small-but-sometimes-large collections
use smallvec::SmallVec;
let mut items: SmallVec<[Item; 8]> = SmallVec::new();
```

### Zero-cost Abstractions

Generics are monomorphized — no runtime cost. Trait objects have vtable overhead.
Use generics when performance matters, trait objects when binary size or
compile times matter more.

```rust
// Monomorphized — separate code per concrete type, inlined
fn process<T: Handler>(item: T) { item.handle(); }

// Dynamic dispatch — single function, vtable lookup
fn process(item: &dyn Handler) { item.handle(); }
```

## Common Pitfalls

- **Cloning to silence the borrow checker**: Fix the ownership structure instead.
  Clone is a code smell unless the data is cheap to copy or you've profiled.
- **Holding a MutexGuard across `.await`**: This blocks the async runtime.
  Clone the data out of the guard before awaiting.
- **Using `String` in function parameters**: Accept `&str` unless you need ownership.
  Same for `Vec<T>` vs `&[T]`.
- **Ignoring clippy**: Run `cargo clippy -- -W clippy::pedantic` and address warnings.
  Many performance and correctness issues are caught by clippy.
- **`.unwrap()` in production code**: Use `?`, `.expect("message")`, or match.
  Reserve `.unwrap()` for tests and places where `None`/`Err` is provably impossible.
- **Forgetting to pin futures**: When storing futures in structs or passing them
  to combinators, they may need `Pin<Box<dyn Future>>`. Use `Box::pin()`.
