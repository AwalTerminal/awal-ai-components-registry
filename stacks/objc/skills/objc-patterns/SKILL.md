# Objective-C Patterns

## Memory Management
- Use ARC (Automatic Reference Counting) — understand `strong`, `weak`, and `unsafe_unretained`
- Use `weak` for delegates and parent references to avoid retain cycles
- Use `__block` for variables modified inside blocks, `__weak` for self-references in blocks
- Break retain cycles in blocks: `__weak typeof(self) weakSelf = self;`
- Use `@autoreleasepool` for loops creating many temporary objects

## Design Patterns
- Use the delegate pattern with protocols for callbacks and customization
- Use `NSNotificationCenter` for one-to-many communication
- Use KVO (`addObserver:forKeyPath:`) sparingly — prefer explicit delegation
- Use categories to extend existing classes without subclassing
- Use class extensions (anonymous categories) for private method declarations

## Error Handling
- Use `NSError **` out-parameters for recoverable errors — check the return value first
- Use `@try/@catch` only for programming errors, not control flow
- Use `NSAssert` for invariants during development — strip in release builds
- Return `nil` with an `NSError` for factory methods that can fail

## Collections and Data
- Use `NS_ENUM` and `NS_OPTIONS` for type-safe enumerations
- Prefer `NSDictionary`, `NSArray`, `NSSet` with lightweight generics: `NSArray<NSString *> *`
- Use modern literal syntax: `@[]`, `@{}`, `@YES`, `@42`
- Use `NSPredicate` and `NSSortDescriptor` for filtering and sorting collections

## Project Structure
- Use `.h` for public interface, `.m` for implementation — keep headers minimal
- Group files by feature in Xcode groups that mirror the filesystem
- Use CocoaPods or SPM for dependency management
- Prefix class names with a 2-3 letter project prefix to avoid collisions
