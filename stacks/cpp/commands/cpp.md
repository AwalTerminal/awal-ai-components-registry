# C++ Commands

## CMake Build
- `cmake -B build -DCMAKE_BUILD_TYPE=Debug` — configure debug build
- `cmake -B build -DCMAKE_BUILD_TYPE=Release` — configure release build
- `cmake --build build` — compile the project
- `cmake --build build -j$(nproc)` — compile with all cores
- `cmake --build build --target tests` — build only tests
- `cmake --install build --prefix /usr/local` — install built artifacts

## Testing
- `ctest --test-dir build` — run all tests via CTest
- `ctest --test-dir build -R "TestName"` — run tests matching pattern
- `ctest --test-dir build --output-on-failure` — show output for failed tests
- `./build/tests` — run GoogleTest/Catch2 binary directly
- `./build/tests --gtest_filter="Suite.Test"` — run specific GoogleTest

## Formatting and Linting
- `clang-format -i src/*.cpp include/*.hpp` — format files in place
- `clang-format --dry-run --Werror src/*.cpp` — check formatting (CI)
- `clang-tidy src/*.cpp -p build/` — run static analysis
- `cppcheck --enable=all src/` — additional static analysis

## Package Managers
- `conan install . --build=missing` — install Conan dependencies
- `conan create .` — build and package for Conan
- `vcpkg install fmt spdlog` — install vcpkg packages
- `cmake -B build -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake` — configure with vcpkg

## Debugging and Profiling
- `cmake -B build -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` — debug build with compile commands (for clangd)
- `valgrind --leak-check=full ./build/app` — check for memory leaks (Linux)
- `cmake -B build -DCMAKE_CXX_FLAGS="-fsanitize=address,undefined"` — build with sanitizers

## Compilation
- `g++ -std=c++20 -O2 -Wall -Wextra -o app main.cpp` — quick single-file compile
- `clang++ -std=c++23 -stdlib=libc++ -O2 -o app main.cpp` — Clang with C++23
