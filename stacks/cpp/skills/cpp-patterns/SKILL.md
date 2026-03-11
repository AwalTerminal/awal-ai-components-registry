# C++ Patterns

## Modern C++ (17/20/23)
- Use `auto` for type deduction when the type is obvious from context
- Use `std::optional` instead of sentinel values or nullable pointers
- Use `std::variant` over unions with type tags
- Use `std::string_view` for non-owning string parameters
- Use structured bindings: `auto [key, value] = *map.begin();`
- Use `constexpr` and `consteval` for compile-time computation

## Memory Management
- Use RAII — acquire resources in constructors, release in destructors
- Use `std::unique_ptr` for exclusive ownership, `std::shared_ptr` for shared
- Avoid raw `new`/`delete` — use `std::make_unique` / `std::make_shared`
- Use `std::span` for non-owning views of contiguous memory
- Follow the Rule of Five (or Rule of Zero) for special member functions

## Error Handling
- Use exceptions for truly exceptional conditions
- Use `std::expected` (C++23) or `Result`-like types for expected failures
- Use `noexcept` on move constructors, destructors, and swap
- Use `static_assert` for compile-time checks

## Concurrency
- Use `std::jthread` over `std::thread` — it auto-joins and supports stop tokens
- Use `std::mutex` with `std::lock_guard` or `std::scoped_lock`
- Use `std::atomic` for lock-free primitives
- Use `std::async` / `std::future` for simple task parallelism
- Avoid data races — use thread sanitizer (`-fsanitize=thread`)

## Build & Tooling
- Use CMake as the build system with `target_*` commands
- Use `clang-tidy` and `clang-format` for static analysis and formatting
- Use sanitizers: ASan, UBSan, TSan during development
- Use `vcpkg` or `conan` for dependency management
- Prefer `#include <header>` over `"header"` for standard/third-party libs
