# Zig Commands

## Build
- `zig build` — build the project using build.zig
- `zig build -Doptimize=Debug` — debug build (default)
- `zig build -Doptimize=ReleaseSafe` — release with safety checks
- `zig build -Doptimize=ReleaseFast` — maximum performance
- `zig build -Doptimize=ReleaseSmall` — minimize binary size
- `zig build run` — build and run the executable
- `zig build -Dtarget=x86_64-linux` — cross-compile for Linux
- `zig build -Dtarget=aarch64-macos` — cross-compile for macOS ARM

## Testing
- `zig build test` — run all tests via build.zig
- `zig test src/main.zig` — run tests in a specific file
- `zig test src/main.zig --test-filter "parse"` — run tests matching a pattern

## Formatting
- `zig fmt .` — format all Zig files in current directory
- `zig fmt src/main.zig` — format a specific file
- `zig fmt --check .` — check formatting without modifying (CI)

## Single File Compilation
- `zig run src/main.zig` — compile and run a single file
- `zig build-exe src/main.zig` — compile a single file to executable
- `zig build-lib src/lib.zig` — compile a single file to library

## C Interop
- `zig cc file.c -o output` — use Zig as a C compiler
- `zig c++ file.cpp -o output` — use Zig as a C++ compiler
- `zig translate-c header.h` — translate a C header to Zig

## Package Management (zon)
- Edit `build.zig.zon` to add dependencies
- `zig fetch --save <url>` — fetch and save a dependency hash
- `zig build` — automatically fetches declared dependencies

## Debugging
- `zig build -Doptimize=Debug` — include debug info and safety checks
- Use `std.debug.print` for debug output (stripped in release builds)
- Use `@breakpoint()` to trigger a debugger breakpoint
