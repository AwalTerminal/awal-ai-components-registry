# Dart Patterns

## Sound Null Safety

### Non-Nullable by Default
```dart
// All types are non-nullable unless explicitly marked with ?
String name = 'Alice';     // Cannot be null
String? nickname;           // Can be null, defaults to null

// Null-aware operators
String display = nickname ?? 'No nickname';       // Default if null
int? length = nickname?.length;                    // Null-safe access
nickname ??= 'default';                            // Assign only if null

// Null assertion — use sparingly, crashes on null
String forced = nickname!;  // Only when you are certain it is not null
```

### Late Initialization
```dart
// late — defers initialization, checked at access time
late final String config = loadConfig();  // Lazy — computed on first access

// late without initializer — must assign before reading
late String apiKey;
void init() { apiKey = fetchKey(); }
void use() { print(apiKey); }  // Throws LateInitializationError if init() not called

// Prefer late over nullable when the value will always be set before use
// but cannot be set in the constructor (e.g., lifecycle methods)
```

### Promoting Nullable Types
```dart
void process(String? input) {
  if (input == null) return;
  // input is promoted to String here — no cast needed
  print(input.length);

  // Promotion works with local variables, not fields
  // For fields, assign to a local first:
  final value = this.nullableField;
  if (value == null) return;
  print(value.length);  // Promoted
}
```

## Extension Types (Dart 3.3+)

### Zero-Cost Wrappers
```dart
// Extension types compile away — no runtime overhead
extension type UserId(String value) {
  // Validation in the constructor
  UserId.validated(String value) : this(value) {
    if (value.isEmpty) throw ArgumentError('UserId cannot be empty');
  }

  bool get isTemporary => value.startsWith('tmp_');
}

extension type Meters(double value) {
  Meters operator +(Meters other) => Meters(value + other.value);
  Meters operator *(double factor) => Meters(value * factor);
  Feet toFeet() => Feet(value * 3.28084);
}

extension type Feet(double value) {}

// Type safety without allocation cost
void setDistance(Meters m) { /* ... */ }
setDistance(Meters(100));
// setDistance(Feet(328));  // Compile error — Feet is not Meters
```

## Sealed Classes and Exhaustive Matching (Dart 3+)

### Algebraic Data Types
```dart
sealed class Result<T> {
  const Result();
}
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}
class Failure<T> extends Result<T> {
  final String message;
  final Object? error;
  const Failure(this.message, [this.error]);
}
class Loading<T> extends Result<T> {
  const Loading();
}

// Exhaustive switch — compiler enforces all cases handled
String display<T>(Result<T> result) => switch (result) {
  Success(:final value) => 'Got: $value',
  Failure(:final message) => 'Error: $message',
  Loading() => 'Loading...',
};
```

### Pattern Matching
```dart
// Destructuring records
final (String name, int age) = getUser();

// Object patterns with when guards
String categorize(Shape shape) => switch (shape) {
  Circle(radius: var r) when r > 100 => 'large circle',
  Circle(radius: var r) => 'circle r=$r',
  Rectangle(width: var w, height: var h) when w == h => 'square ${w}x$h',
  Rectangle(:var width, :var height) => 'rect ${width}x$height',
};

// List patterns
String describeList(List<int> list) => switch (list) {
  [] => 'empty',
  [var single] => 'single: $single',
  [var first, ...var rest] => 'first: $first, rest: $rest',
};

// Map patterns
void processJson(Map<String, dynamic> json) {
  if (json case {'type': 'user', 'name': String name, 'age': int age}) {
    print('User $name, age $age');
  }
}
```

## Mixins and Generics

### Mixins for Shared Behavior
```dart
mixin Loggable {
  void log(String message) => print('[${runtimeType}] $message');
}

mixin Cacheable<T> {
  final Map<String, T> _cache = {};

  T? getFromCache(String key) => _cache[key];

  void putInCache(String key, T value) {
    _cache[key] = value;
  }

  void clearCache() => _cache.clear();
}

// Constrained mixin — only usable on specific base class
mixin Serializable on Entity {
  Map<String, dynamic> toJson();
}

class UserService with Loggable, Cacheable<User> {
  User fetchUser(String id) {
    final cached = getFromCache(id);
    if (cached != null) return cached;
    log('Cache miss for $id');
    final user = _fetchFromApi(id);
    putInCache(id, user);
    return user;
  }
}
```

### Generics with Bounds
```dart
// Upper bound constraint
T max<T extends Comparable<T>>(T a, T b) => a.compareTo(b) >= 0 ? a : b;

// Generic class with multiple bounds via intersection types (use extension types or abstract classes)
abstract class Repository<T extends Entity> {
  Future<T?> findById(String id);
  Future<void> save(T entity);
  Future<List<T>> findAll({int limit = 100, int offset = 0});
}
```

## Concurrency

### Isolates for CPU-Bound Work
```dart
// compute() — runs a function in a separate isolate
Future<List<int>> sortLargeList(List<int> data) async {
  return await Isolate.run(() {
    final copy = List.of(data);  // Isolates get their own copy
    copy.sort();
    return copy;
  });
}

// For long-running isolates, use Isolate.spawn with SendPort/ReceivePort
// for bidirectional communication — the spawned isolate gets its own memory
```

### Streams and StreamController
```dart
// Custom stream with StreamController
class EventBus {
  final _controller = StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get events => _controller.stream;

  // Filtered stream
  Stream<T> on<T extends AppEvent>() =>
      _controller.stream.whereType<T>();

  void emit(AppEvent event) => _controller.add(event);

  void dispose() => _controller.close();
}

// Stream transformations
final subscription = eventBus.on<UserEvent>()
    .where((e) => e.userId == currentUserId)
    .map((e) => e.toNotification())
    .distinct()
    .listen(
      (notification) => showNotification(notification),
      onError: (e) => logError(e),
      cancelOnError: false,
    );

// Always cancel subscriptions to prevent memory leaks
subscription.cancel();
```

### Completer for Callback Bridging
```dart
// Bridge callback-based APIs into Futures
Future<String> readFileCallback(String path) {
  final completer = Completer<String>();
  legacyRead(path,
    onSuccess: (data) => completer.complete(data),
    onError: (err) => completer.completeError(err),
  );
  return completer.future;
}
```

## Error Handling

### Typed Exception Hierarchy
```dart
sealed class AppException implements Exception {
  final String message;
  final Object? cause;
  const AppException(this.message, [this.cause]);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkException extends AppException {
  final int? statusCode;
  const NetworkException(super.message, {this.statusCode, super.cause});
}

class ValidationException extends AppException {
  final Map<String, String> fieldErrors;
  const ValidationException(this.fieldErrors)
      : super('Validation failed');
}

class NotFoundException extends AppException {
  const NotFoundException(String resource, String id)
      : super('$resource $id not found');
}

// Catch specific types
try {
  await fetchUser(id);
} on NotFoundException catch (e) {
  showNotFound(e.message);
} on NetworkException catch (e) {
  showRetryDialog(e.message);
} on AppException catch (e) {
  showGenericError(e.message);
}
```

## Performance Patterns

### Const Constructors
```dart
// const enables compile-time constant folding and identity-based caching
class Padding {
  final double value;
  const Padding(this.value);
  const Padding.zero() : value = 0;
}

// These are the same instance in memory
const a = Padding(16);
const b = Padding(16);
assert(identical(a, b));  // true

// In Flutter, const widgets skip rebuild entirely
// Always add const where possible — the analyzer warns about missing const
```

### Tear-Offs
```dart
// Reference functions without wrapping in a lambda — avoids closure allocation
final users = jsonList.map(User.fromJson).toList();  // Constructor tear-off
items.where(validator.check);                          // Method tear-off
```

### AOT vs JIT Implications
```dart
// JIT (dart run, flutter run debug) — supports hot reload, mirrors, runtime codegen
// AOT (dart compile exe, flutter build) — faster startup, smaller binary, no mirrors

// Patterns affected by AOT:
// - No dart:mirrors — use code generation (json_serializable, freezed) instead
// - No eval() or dynamic code loading
// - Tree shaking removes unused code — avoid relying on reflection-discovered types
// - const values are inlined at compile time — prefer const for configuration
```

## Common Pitfalls

### Forgetting to Await Futures
```dart
// WRONG — future is silently ignored, errors are swallowed
void save(User user) {
  repository.save(user);  // Returns Future<void> — not awaited!
}

// RIGHT — always await or return
Future<void> save(User user) async {
  await repository.save(user);
}

// If intentionally not awaiting, use unawaited() to signal intent
import 'dart:async';
void fireAndForget(User user) {
  unawaited(repository.save(user));
}
```

### Mutating Collections During Iteration
```dart
// WRONG — ConcurrentModificationError
for (final item in list) {
  if (item.isExpired) list.remove(item);
}

// RIGHT — filter to a new list
list.removeWhere((item) => item.isExpired);
```
