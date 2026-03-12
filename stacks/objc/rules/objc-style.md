# Objective-C Style Rules

- Use `clang-format` with a project `.clang-format` config
- Prefix class names with a 2-3 letter project abbreviation: `MYAppDelegate`
- Use `nullable`/`nonnull` annotations on all public API parameters and return types
- Use lightweight generics for collections: `NSArray<NSString *> *` not `NSArray *`
- Use modern `@property` syntax — avoid manual ivar declarations
- Keep `.h` headers minimal — move private methods to class extensions in the `.m` file
- Use `NS_ENUM`/`NS_OPTIONS` instead of bare `enum` for type safety
- Write HeaderDoc or Doxygen comments for all public methods
