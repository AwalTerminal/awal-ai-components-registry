# Objective-C Style Rules

## Formatting
- Use `clang-format` with a project `.clang-format` config — run before every commit
- 4-space indentation (Apple convention)
- Opening brace on same line for methods and control flow
- Keep lines under 120 characters
- One blank line between method implementations

## Naming
- Classes: prefix with 2-3 letter project abbreviation: `MYUserManager`, `ABCNetworkClient`
- Methods: `camelCase`, descriptive, verb-first: `fetchUserWithId:completion:`
- Properties: `camelCase` without prefix: `userName`, `isActive`
- Constants: prefix with `k` + class prefix: `kMYMaxRetryCount`
- Enums: `PascalCase` with type prefix: `ConnectionStateConnected`
- Protocols: use agent noun or `...ing`/`...able`: `UITableViewDelegate`, `NSCoding`
- Categories: `ClassName+Purpose.h`: `NSString+Validation.h`

## Properties
- Use `@property` syntax — avoid manual ivar declarations
- Use `nonatomic` unless thread safety requires `atomic`
- Use `copy` for `NSString`, `NSArray`, `NSSet`, and block properties
- Use `weak` for delegates and parent references
- Use `nullable`/`nonnull` annotations on all public API parameters and return types
- Wrap header declarations in `NS_ASSUME_NONNULL_BEGIN`/`END`

## Types
- Use `NS_ENUM` and `NS_OPTIONS` instead of bare `enum`
- Use lightweight generics for collections: `NSArray<NSString *> *` not `NSArray *`
- Use `instancetype` as return type for init and factory methods
- Use `NS_DESIGNATED_INITIALIZER` to mark the primary initializer

## Methods
- Keep methods under 40 lines — extract helpers into private methods or categories
- Place required protocol methods before optional ones in implementation
- Use `#pragma mark -` to organize method groups in implementation files
- Check optional delegate/protocol methods with `respondsToSelector:` before calling

## Memory
- Understand ARC ownership: `strong`, `weak`, `copy`, `unsafe_unretained`
- Break retain cycles in blocks with `__weak typeof(self) weakSelf = self`
- Use `@autoreleasepool` in tight loops creating temporary objects
- Never call `retain`, `release`, `autorelease`, or `dealloc` directly under ARC

## Headers
- Keep `.h` headers minimal — only expose the public API
- Move private methods, properties, and ivars to class extensions in `.m`
- Use forward declarations (`@class`, `@protocol`) in headers, full imports in `.m`

## Documentation
- Write HeaderDoc or Doxygen comments for all public methods and classes
- Include `@param`, `@return`, `@note` tags for complex methods
- Document threading requirements and ownership semantics

## Swift Interop
- Add `NS_SWIFT_NAME()` annotations for cleaner Swift API naming
- Use `NS_SWIFT_UNAVAILABLE()` for APIs that have better Swift alternatives
- Mark classes as `NS_REFINED_FOR_SWIFT` when providing a Swift overlay
