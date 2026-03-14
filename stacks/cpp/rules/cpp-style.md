# C++ Style Rules

## Naming
- Types and classes: `PascalCase` (`HttpClient`, `EventLoop`)
- Functions and methods: `snake_case` or `camelCase` — be consistent within a project
- Variables and parameters: `snake_case`
- Constants and compile-time values: `kPascalCase` or `UPPER_SNAKE_CASE`
- Private member variables: trailing underscore (`count_`, `data_`)
- Template parameters: `PascalCase` (`typename Key`, `typename Value`)
- Namespaces: `lowercase` (`namespace net`, `namespace utils`)
- Macros (avoid when possible): `UPPER_SNAKE_CASE`

## Formatting
- Use clang-format with a `.clang-format` file for consistency
- Braces on same line (K&R/LLVM style) or next line (Allman) — pick one, be consistent
- 2 or 4 spaces for indentation — match project convention
- Max line length: 100-120 characters
- Include order: related header, C system, C++ standard, other libs, project headers

## Modern C++ Practices
- Prefer `auto` when the type is obvious from the right side of the assignment
- Use `constexpr` and `consteval` over macros for compile-time constants
- Use `std::string_view` for read-only string parameters, not `const std::string&`
- Use structured bindings: `auto [key, value] = pair;`
- Use `std::optional` for values that may not exist, not sentinel values
- Use `std::expected` (C++23) or `Result<T, E>` for fallible operations
- Use `enum class` instead of plain `enum`

## Memory Management
- Follow Rule of 0: let RAII types (smart pointers, containers) manage resources
- Use `std::unique_ptr` for sole ownership — default choice
- Use `std::shared_ptr` only when ownership is genuinely shared
- Never use `new`/`delete` directly — use `std::make_unique`/`std::make_shared`
- Use `std::move` explicitly when transferring ownership
- Mark move constructors and move assignment `noexcept`

## Safety
- Enable warnings: `-Wall -Wextra -Wpedantic -Werror`
- Use `[[nodiscard]]` on functions whose return value should not be ignored
- Use `const` by default on variables, parameters, and methods
- Prefer range-based for loops over index-based
- Use `std::span` (C++20) instead of pointer + size pairs
- Avoid raw C arrays — use `std::array` for fixed size, `std::vector` for dynamic

## Error Handling
- Use exceptions for unrecoverable errors; `std::expected` or error codes for expected failures
- Never throw in destructors
- Use RAII so cleanup happens automatically, even when exceptions propagate
- Catch by `const&`: `catch (const std::exception& e)`
