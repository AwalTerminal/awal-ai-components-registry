# Swift Patterns

## Value Types vs Reference Types

Structs are copied on assignment; classes are shared by reference. Default to structs.

```swift
// Struct — independent copies, no shared mutation bugs
struct Point {
    var x: Double
    var y: Double
}

var a = Point(x: 1, y: 2)
var b = a        // b is an independent copy
b.x = 99        // a.x is still 1

// Class — shared reference, mutations visible to all holders
class Document {
    var title: String
    init(title: String) { self.title = title }
}

let doc1 = Document(title: "Draft")
let doc2 = doc1        // both point to the same object
doc2.title = "Final"   // doc1.title is now "Final"
```

Use classes only when you need: identity (`===`), inheritance, or Objective-C interop.

## Protocol-Oriented Programming

Prefer protocols with default extensions over base classes:

```swift
protocol Cacheable {
    var cacheKey: String { get }
    var ttl: TimeInterval { get }
}

extension Cacheable {
    var ttl: TimeInterval { 300 } // default 5 minutes
}
```

Use protocol composition for flexible APIs: `func save(_ item: Cacheable & Codable)`.

Use `some Protocol` (opaque return types) for zero-cost abstraction.
Avoid `any Protocol` existentials in hot paths -- they heap-allocate and use dynamic dispatch.

## Swift Concurrency

### Async/Await

```swift
func fetchUser(id: UUID) async throws -> User {
    let (data, response) = try await URLSession.shared.data(
        from: URL(string: "/users/\(id)")!
    )
    guard let http = response as? HTTPURLResponse,
          http.statusCode == 200 else {
        throw APIError.badStatus
    }
    return try JSONDecoder().decode(User.self, from: data)
}
```

Bridge from sync contexts with `Task`:

```swift
func viewDidLoad() {
    super.viewDidLoad()
    Task {
        do {
            let user = try await fetchUser(id: currentID)
            nameLabel.text = user.name  // OK if @MainActor
        } catch {
            showError(error)
        }
    }
}
```

### Actors

```swift
actor ImageCache {
    private var store: [URL: UIImage] = [:]

    func image(for url: URL) -> UIImage? {
        store[url]
    }

    func set(_ image: UIImage, for url: URL) {
        store[url] = image
    }
}

// Call site — must await because actor protects its state
let cache = ImageCache()
let img = await cache.image(for: someURL)
```

Use `nonisolated` for properties that don't touch mutable state:

```swift
actor DatabaseManager {
    let connectionString: String  // immutable — safe
    nonisolated var description: String {
        "DB(\(connectionString))"
    }
}
```

### Structured Concurrency

```swift
// Parallel independent work with async let
async let profile = fetchProfile(id: userID)
async let posts = fetchPosts(for: userID)
async let followers = fetchFollowers(for: userID)
let dashboard = try await Dashboard(
    profile: profile, posts: posts, followers: followers
)

// Dynamic concurrency with TaskGroup
func fetchAll(ids: [UUID]) async throws -> [User] {
    try await withThrowingTaskGroup(of: User.self) { group in
        for id in ids {
            group.addTask { try await fetchUser(id: id) }
        }
        var users: [User] = []
        for try await user in group {
            users.append(user)
        }
        return users
    }
}
```

### Sendable

Types crossing actor boundaries must be `Sendable`. Value types composed
of Sendable fields are implicitly Sendable. For classes, use `@unchecked Sendable`
only when you guarantee thread safety yourself (e.g., internal locking).

```swift
struct Payload: Sendable {
    let id: UUID
    let data: Data
}

// Only if you've manually ensured thread safety
final class AtomicCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var _value = 0
    var value: Int {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }
}
```

## Optionals Mastery

```swift
// guard let — early exit, keeps the happy path unindented
func process(input: String?) throws -> Result {
    guard let input else { throw ValidationError.missing }
    return transform(input)
}

// map/flatMap on optionals — avoid nested if-let
let length: Int? = optionalString.map { $0.count }
let parsed: Int? = optionalString.flatMap { Int($0) }

// Nil-coalescing with meaningful defaults
let name = user.nickname ?? user.email ?? "Anonymous"

// Optional chaining
let city = user.address?.city?.uppercased()
```

Never force-unwrap (`!`) outside of tests or `fatalError` paths with a clear message.

## Error Handling

```swift
// Typed throws (Swift 6+)
enum ParseError: Error {
    case invalidFormat(line: Int)
    case missingField(String)
}

func parse(data: Data) throws(ParseError) -> Config {
    guard let text = String(data: data, encoding: .utf8) else {
        throw .invalidFormat(line: 0)
    }
    // ...
}

// Result for synchronous fallible operations
func validate(email: String) -> Result<Email, ValidationError> {
    guard email.contains("@") else {
        return .failure(.invalidEmail(email))
    }
    return .success(Email(email))
}

// Converting between Result and throws
let result = Result { try parse(data: rawData) }
let value = try result.get()
```

## Property Wrappers

```swift
@propertyWrapper
struct Clamped<V: Comparable> {
    private var value: V
    let range: ClosedRange<V>

    var wrappedValue: V {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }

    init(wrappedValue: V, _ range: ClosedRange<V>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }
}

struct AudioSettings {
    @Clamped(0...100) var volume: Int = 50
    @Clamped(0.0...1.0) var pan: Double = 0.5
}
```

## Result Builders

Define custom DSLs with `@resultBuilder`. Implement `buildBlock`, `buildOptional`,
`buildEither(first:)`, and `buildEither(second:)` for composable declarative syntax.
SwiftUI's `@ViewBuilder` is the canonical example.

## Memory Management (ARC)

```swift
// Weak reference — breaks retain cycles, becomes nil when target deallocates
class Parent {
    var child: Child?
}

class Child {
    weak var parent: Parent?  // weak to avoid cycle
}

// Unowned — like weak but crashes if accessed after deallocation
// Use only when you can guarantee the referenced object outlives the reference
class Customer {
    let card: CreditCard
    init() { self.card = CreditCard(owner: self) }
}

class CreditCard {
    unowned let owner: Customer  // owner always outlives the card
}

// Capture lists in closures
class ViewModel {
    var onUpdate: (() -> Void)?

    func bind() {
        onUpdate = { [weak self] in
            guard let self else { return }
            self.refresh()
        }
    }
}
```

## Performance Patterns

### Copy-on-Write

Swift collections use COW. Custom value types with heap storage should too:

```swift
struct LargeBuffer {
    private var storage: StorageRef

    mutating func modify(at index: Int, value: UInt8) {
        // Copy storage only if shared
        if !isKnownUniquelyReferenced(&storage) {
            storage = storage.copy()
        }
        storage.data[index] = value
    }
}
```

### Avoid Existential Overhead

```swift
// Slow — each call goes through witness table + possible heap alloc
func sum(_ values: [any Numeric]) -> Double { ... }

// Fast — monomorphized at compile time
func sum<T: Numeric>(_ values: [T]) -> T { ... }
```

### ContiguousArray

Use `ContiguousArray` instead of `Array` when element type might be a class
and you need guaranteed contiguous storage (no NSArray bridging):

```swift
var buffer = ContiguousArray<CGPoint>()
buffer.reserveCapacity(10_000)
```

### Reducing Allocations

Pre-size collections: `Dictionary<String, Int>(minimumCapacity: 1000)`.
Use `withUnsafeBufferPointer` for bulk memory operations.

## Common Pitfalls

- **Accidental copies of large structs**: Pass by `inout` or use a class when mutation
  is the primary operation and the struct contains large heap-backed storage.
- **Blocking the main actor**: Never do synchronous I/O or heavy computation on
  `@MainActor`. Offload to a detached task or a custom actor.
- **Retain cycles in closures**: Always audit closures stored as properties.
  Use `[weak self]` for long-lived closures, `[unowned self]` only with lifetime proof.
- **Forgetting Sendable conformance**: Compiler warnings are progressive; enable
  strict concurrency checking (`-strict-concurrency=complete`) early.
- **Using `Any` as an escape hatch**: Prefer generics or protocol existentials with
  proper constraints. `Any` erases all type info and defers errors to runtime.
- **Large enums with associated values**: Each case takes memory equal to the
  largest case. If sizes vary wildly, box the large case with an indirect enum.

```swift
// Without indirect — every Color value is as large as the gradient case
enum Color {
    case solid(UInt32)
    indirect case gradient([Color], angle: Double)  // heap-allocated
}
```
