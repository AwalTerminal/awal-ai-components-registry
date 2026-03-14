# Lua Style Rules

## Formatting
- Use `luacheck` for linting and `StyLua` or `lua-format` for formatting
- 2-space or 4-space indentation — be consistent per project
- Keep lines under 100 characters
- One blank line between function definitions

## Naming
- Variables and functions: `snake_case` (`process_data`, `user_count`)
- Classes/constructors: `PascalCase` (`HttpClient`, `Vec2`)
- Constants: `UPPER_SNAKE_CASE` (`MAX_RETRIES`, `DEFAULT_PORT`)
- Module-private functions: prefix with `_` (`_validate_input`)
- Boolean variables: prefix with `is_` or `has_` (`is_valid`, `has_data`)

## Variables
- Declare ALL variables with `local` — never pollute the global namespace
- Use `local` even for module-level variables within a file
- Declare variables as close to their first use as possible
- Localize frequently used standard library functions at the top: `local insert = table.insert`

## Functions
- Use colon syntax for methods that use `self`: `function Obj:method()`
- Use dot syntax for static/class functions: `function Obj.create()`
- Keep functions under 40 lines — extract helpers
- Return `nil, error_message` for expected errors — reserve `error()` for programming mistakes
- Avoid variadic `...` args unless building generic wrappers

## Tables
- Use consistent table constructor style — trailing comma on multi-line tables
- Use `#t` only for sequence-like tables (continuous integer keys from 1)
- Iterate with `ipairs` for sequences, `pairs` for all key-value pairs
- Avoid mixing array and hash parts in the same table

## Modules
- Each file returns a single table — the module's public API
- Never modify global state from a module
- Keep the return table at the bottom of the file
- Use `require` for imports — it caches automatically

## Error Handling
- Check return values from `pcall`/`xpcall` — never ignore errors
- Use `error()` with a table for structured errors when needed
- Always close resources (files, connections) even on error paths

## Comments
- Use `--` for single-line comments
- Use `--[[ ]]` for block comments — never for disabling code in production
- Document public module functions with parameter and return descriptions

## Linting
- Run `luacheck .` before every commit — fix all warnings
- Configure `.luacheckrc` for project-specific globals and rules
- Enable `unused` and `redefined` checks
