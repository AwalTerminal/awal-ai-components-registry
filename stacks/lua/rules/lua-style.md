# Lua Style Rules

- Use `luacheck` and fix all warnings before committing
- Use `snake_case` for variables and functions, `PascalCase` for classes/constructors
- Declare all variables with `local` — never pollute the global namespace
- Use 2-space or 3-space indentation consistently per project
- Return `nil, err` for expected errors — reserve `error()` for programming mistakes
- Keep modules self-contained — each file returns a single table
- Use `--` for single-line comments, `--[[ ]]` for block comments
- Avoid `goto` — use early returns and structured control flow instead
