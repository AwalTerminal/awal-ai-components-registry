# C++ Patterns

## Concepts (C++20)

```cpp
// Define a concept — compile-time constraint on template parameters
template<typename T>
concept Hashable = requires(T a) {
    { std::hash<T>{}(a) } -> std::convertible_to<std::size_t>;
};

template<typename T>
concept Serializable = requires(T obj, std::ostream& os) {
    { obj.serialize(os) } -> std::same_as<void>;
    { T::deserialize(os) } -> std::same_as<T>;
};

// Use concepts to constrain templates
template<Hashable Key, typename Value>
class HashMap {
    // Key is guaranteed to be hashable at compile time
};

// Shorthand with auto
void process(Serializable auto const& item) {
    item.serialize(std::cout);
}
```

## Ranges (C++20)

```cpp
#include <ranges>
#include <algorithm>

// Composable, lazy transformations
auto result = numbers
    | std::views::filter([](int n) { return n % 2 == 0; })
    | std::views::transform([](int n) { return n * n; })
    | std::views::take(10);

// Range algorithms — no begin/end boilerplate
std::ranges::sort(employees, {}, &Employee::salary);

auto it = std::ranges::find_if(employees, [](const auto& e) {
    return e.department == "Engineering";
});

// views::zip (C++23)
for (auto [name, score] : std::views::zip(names, scores)) {
    fmt::println("{}: {}", name, score);
}
```

## Smart Pointers and RAII

```cpp
// unique_ptr — sole ownership, zero overhead
auto conn = std::make_unique<DatabaseConnection>(config);
auto result = conn->query("SELECT * FROM users");
// conn automatically closed when it goes out of scope

// shared_ptr — shared ownership, reference counted
class EventBus {
    std::vector<std::shared_ptr<Listener>> listeners_;
public:
    void subscribe(std::shared_ptr<Listener> listener) {
        listeners_.push_back(std::move(listener));
    }
};

// weak_ptr — non-owning observer, breaks cycles
class Node {
    std::vector<std::shared_ptr<Node>> children_;
    std::weak_ptr<Node> parent_;  // Avoids circular reference
public:
    void set_parent(std::shared_ptr<Node> p) {
        parent_ = p;
    }
    std::shared_ptr<Node> get_parent() const {
        return parent_.lock();  // Returns nullptr if expired
    }
};
```

## Move Semantics and Rule of 5/0

```cpp
// Rule of 0 — prefer this: let compiler handle everything
struct Config {
    std::string name;
    std::vector<int> values;
    std::unique_ptr<Logger> logger;
    // No destructor, copy/move constructors, or assignment operators needed
};

// Rule of 5 — when managing a raw resource
class Buffer {
    std::byte* data_;
    std::size_t size_;
public:
    explicit Buffer(std::size_t size) : data_(new std::byte[size]), size_(size) {}
    ~Buffer() { delete[] data_; }

    Buffer(const Buffer& other) : data_(new std::byte[other.size_]), size_(other.size_) {
        std::memcpy(data_, other.data_, size_);
    }
    Buffer(Buffer&& other) noexcept : data_(other.data_), size_(other.size_) {
        other.data_ = nullptr;
        other.size_ = 0;
    }
    Buffer& operator=(Buffer other) {  // Copy-and-swap idiom
        std::swap(data_, other.data_);
        std::swap(size_, other.size_);
        return *this;
    }
};
```

## std::expected (C++23)

```cpp
#include <expected>

std::expected<User, Error> find_user(int id) {
    auto row = db.query("SELECT * FROM users WHERE id = ?", id);
    if (!row)
        return std::unexpected(Error::NotFound);

    return User{row->get<std::string>("name"), row->get<int>("age")};
}

// Monadic operations
auto result = find_user(42)
    .and_then([](User u) -> std::expected<Profile, Error> {
        return load_profile(u.id);
    })
    .transform([](Profile p) { return p.display_name; });
```

## Structured Bindings and Fold Expressions

```cpp
// Structured bindings
auto [name, age, email] = get_user_tuple();

for (auto& [key, value] : config_map) {
    fmt::println("{} = {}", key, value);
}

// Fold expressions — variadic template operations
template<typename... Args>
auto sum(Args... args) { return (args + ...); }

template<typename T, typename... Validators>
bool validate_all(const T& value, Validators... validators) {
    return (validators(value) && ...);
}
```

## Concurrency

```cpp
// std::jthread — auto-joining, supports stop tokens
auto t = std::jthread([](std::stop_token stop) {
    while (!stop.stop_requested()) { process_next_item(); }
});

// Lock-free atomic operations
std::atomic<int64_t> count{0};
count.fetch_add(1, std::memory_order_relaxed);

// Scoped lock (C++17) — locks multiple mutexes without deadlock
std::scoped_lock lock(mutex_a, mutex_b);
```

## Constexpr and Compile-Time Computation

```cpp
// Compile-time evaluation
consteval std::size_t bucket_count(std::size_t expected_elements) {
    return expected_elements * 4 / 3 + 1;
}

constexpr auto BUCKETS = bucket_count(1000);

// constexpr string processing (C++20)
constexpr bool is_valid_identifier(std::string_view s) {
    if (s.empty() || !std::isalpha(s[0])) return false;
    for (char c : s)
        if (!std::isalnum(c) && c != '_') return false;
    return true;
}

static_assert(is_valid_identifier("hello_world"));
static_assert(!is_valid_identifier("123abc"));
```

## Performance Patterns

- **Cache-friendly**: use `std::vector` over `std::list`; prefer SoA (Struct of Arrays) over AoS for hot loops
- **Avoid copies**: pass large objects by `const&`; return by value (NRVO applies)
- **Reserve capacity**: `vec.reserve(n)` before bulk insertion
- **String views**: use `std::string_view` for read-only string parameters
- **Small buffer optimization**: `std::string`, `std::function` use SBO for small sizes
- **SIMD**: use compiler intrinsics or libraries like `xsimd` for data-parallel operations

## CMake Patterns

```cmake
cmake_minimum_required(VERSION 3.20)
project(MyApp LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(core STATIC src/core.cpp)
target_include_directories(core PUBLIC include/)

add_executable(app src/main.cpp)
target_link_libraries(app PRIVATE core)

# Testing with GoogleTest via FetchContent
include(FetchContent)
FetchContent_Declare(googletest GIT_REPOSITORY https://github.com/google/googletest.git GIT_TAG v1.14.0)
FetchContent_MakeAvailable(googletest)
enable_testing()
add_executable(tests tests/core_test.cpp)
target_link_libraries(tests PRIVATE core GTest::gtest_main)
gtest_discover_tests(tests)
```

## Testing

```cpp
// GoogleTest
TEST(MoneyTest, AddSameCurrency) {
    auto result = Money{100, "USD"} + Money{50, "USD"};
    EXPECT_EQ(result.amount(), 150);
}

TEST(MoneyTest, AddDifferentCurrencyThrows) {
    EXPECT_THROW(Money{100, "USD"} + Money{50, "EUR"}, CurrencyMismatchError);
}

// Catch2
TEST_CASE("Vector operations", "[vector]") {
    std::vector<int> v;
    SECTION("starts empty") { REQUIRE(v.empty()); }
    SECTION("grows when added") { v.push_back(1); REQUIRE(v.size() == 1); }
}
```
