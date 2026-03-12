# Lua Patterns

## Tables
- Tables are the only data structure — use them for arrays, maps, objects, and modules
- Use integer keys for sequences, string keys for records
- Check length with `#t` for sequences — be aware it only works for continuous integer keys
- Use `table.insert`, `table.remove`, `table.sort` for sequence manipulation
- Iterate with `ipairs` for sequences, `pairs` for all key-value pairs

## Error Handling
- Use `pcall` (protected call) to catch errors: `local ok, err = pcall(fn)`
- Use `xpcall` to catch errors with a custom error handler for stack traces
- Return `nil, error_message` for expected failures — reserve `error()` for bugs
- Validate types at function boundaries with explicit checks

## Modules and OOP
- Define modules as tables returned from a file: `local M = {} ... return M`
- Use metatables and `__index` for prototype-based OOP
- Prefer composition over inheritance — Lua's inheritance is shallow by convention
- Use local variables for performance — avoid globals in hot paths
- Use `require` for module loading — it caches results automatically

## Performance
- Use `local` for all variables — global access is slower
- Pre-compute values outside loops — Lua doesn't optimize loop-invariant expressions
- Use LuaJIT for performance-critical applications
- Avoid string concatenation in loops — use `table.concat`

## Embedding
- Keep the Lua API surface small when embedding — expose only what's needed
- Use `lua_pcall` from C for error-safe function calls
- Leverage Lua coroutines for cooperative multitasking in game loops
- Use `userdata` for C-managed objects, `lightuserdata` for pointers
