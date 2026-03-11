# Zig Patterns

## Memory Management
- Use allocators explicitly — prefer `std.mem.Allocator` parameter over globals
- Use `defer` and `errdefer` for cleanup — they make resource management safe
- Use `ArenaAllocator` for batch allocations that share a lifetime
- Use `FixedBufferAllocator` when you can bound memory usage at compile time
- Always handle allocation failures — Zig makes `error.OutOfMemory` explicit

## Error Handling
- Use error unions (`!`) for functions that can fail
- Use `try` for propagation, `catch` for handling
- Return errors instead of panicking — `@panic` is for bugs, not runtime errors
- Use `errdefer` to clean up on error paths
- Use error sets to document exactly which errors a function can return

## Comptime
- Use `comptime` parameters for generic programming
- Use `@typeInfo` for compile-time reflection
- Prefer comptime over runtime when the data is known at build time
- Use `inline for` over runtime loops when iterating comptime-known slices

## Concurrency
- Use `std.Thread` for OS threads
- Use `async`/`await` for cooperative concurrency (with event loop)
- Use atomics (`std.atomic`) for lock-free data structures
- Prefer message passing over shared mutable state

## Build System
- Use `build.zig` for all build configuration — no Makefiles needed
- Use `@import("builtin")` to detect target OS/arch at comptime
- Use `addModule` for internal dependencies
- Link C libraries with `linkSystemLibrary` when needed
