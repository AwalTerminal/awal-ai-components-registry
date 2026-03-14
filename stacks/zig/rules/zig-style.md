# Zig Style Rules

## Naming
- Types: `PascalCase` (`ArrayList`, `HashMap`, `TcpStream`)
- Functions and methods: `camelCase` (`getValue`, `processItem`)
- Variables and parameters: `snake_case` (`file_path`, `max_retries`)
- Constants (comptime known): `snake_case` (`max_buffer_size`)
- Compile-time type functions: `PascalCase` (`HashMap(K, V)`)
- Error values: `PascalCase` (`error.FileNotFound`, `error.OutOfMemory`)

## Formatting
- Use `zig fmt` — the canonical formatter; no configuration needed
- 4 spaces for indentation
- No trailing whitespace
- One statement per line
- Blank line between function definitions

## Memory
- Always accept `std.mem.Allocator` as a parameter — never use global allocators
- Always pair allocations with `defer`/`errdefer` for cleanup
- Use `errdefer` to clean up partially initialized resources on error
- Use `ArenaAllocator` when many allocations share a lifetime
- Use `testing.allocator` in tests — it automatically detects leaks

## Error Handling
- Use error unions (`!T`) for all fallible functions
- Use `try` to propagate errors, `catch` to handle them
- Return specific error sets, not `anyerror`, when possible
- Use `errdefer` for cleanup that should only run on error
- Reserve `@panic` and `unreachable` for programmer bugs, never for runtime errors

## Types and Data
- Use `?T` (optional) instead of sentinel values
- Use `orelse` for providing defaults to optionals
- Use packed structs only for hardware/protocol layouts
- Use `extern struct` for C interop structures
- Prefer slices (`[]T`) over raw pointers (`[*]T`)

## Functions
- Keep functions short and focused — one responsibility
- Accept the most general type that works (e.g., `[]const u8` over `*const [N]u8`)
- Use `comptime` parameters for generic programming instead of macros or codegen
- Mark parameters `const` when they should not be modified
- Use `inline` only when measurably beneficial — trust the optimizer

## Testing
- Write tests adjacent to the code they test (in the same file)
- Use `testing.allocator` to catch memory leaks
- Use `testing.expectEqual`, `testing.expectError`, `testing.expectEqualStrings`
- Use `comptime { _ = nested_test_struct; }` to reference nested test containers
