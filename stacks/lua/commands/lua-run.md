# Lua Run & Test Commands

## Running

- `lua script.lua` — run with standard Lua
- `luajit script.lua` — run with LuaJIT (faster, FFI support)
- `lua -i script.lua` — run script then enter interactive mode
- `lua -e "print('hello')"` — evaluate expression
- `lua -l module_name` — require a module before running

## Package Management (LuaRocks)

- `luarocks install package_name` — install a package
- `luarocks install --deps-only rockspec.rockspec` — install project dependencies
- `luarocks make` — build and install the local rock
- `luarocks make --local` — install to user directory
- `luarocks list` — list installed packages
- `luarocks search package_name` — search for packages
- `luarocks remove package_name` — uninstall a package
- `luarocks init` — initialize a new project with rockspec

## Testing (Busted)

- `busted` — run all tests (discovers *_spec.lua files)
- `busted --verbose` — run with detailed output
- `busted spec/specific_spec.lua` — run a single test file
- `busted --filter "pattern"` — run tests matching a pattern
- `busted --tags "unit"` — run tests with specific tags
- `busted --coverage` — run with code coverage (requires luacov)
- `busted -o TAP` — output in TAP format

## Linting

- `luacheck .` — lint all Lua files in current directory
- `luacheck src/ spec/` — lint specific directories
- `luacheck --no-unused-args src/` — lint ignoring unused arguments
- `luacheck --config .luacheckrc .` — lint with project config

## Coverage

- `luacov` — generate coverage report (after running tests with coverage)
- `luacov-console` — display coverage in terminal
- `busted --coverage && luacov` — run tests with coverage then report

## Debugging

- `lua -e "require('mobdebug').listen()"` — start remote debugger
- `lua -d script.lua` — run with debug library (if available)

## Formatting

- `stylua .` — format all Lua files (StyLua)
- `stylua --check .` — check formatting without modifying
- `lua-format -i src/*.lua` — format with LuaFormatter
