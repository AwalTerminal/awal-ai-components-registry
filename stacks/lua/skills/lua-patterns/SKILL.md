# Lua Patterns

## Metatables and OOP

```lua
-- Class pattern using metatables
local Animal = {}
Animal.__index = Animal

function Animal.new(name, sound)
    local self = setmetatable({}, Animal)
    self.name = name
    self.sound = sound
    return self
end

function Animal:speak()
    return self.name .. " says " .. self.sound
end

-- Inheritance
local Dog = setmetatable({}, { __index = Animal })
Dog.__index = Dog

function Dog.new(name)
    local self = Animal.new(name, "Woof")
    return setmetatable(self, Dog)
end

function Dog:fetch(item)
    return self.name .. " fetches " .. item
end

local rex = Dog.new("Rex")
print(rex:speak())       -- "Rex says Woof"
print(rex:fetch("ball")) -- "Rex fetches ball"

-- Operator overloading via metamethods
local Vec2 = {}
Vec2.__index = Vec2

function Vec2.new(x, y)
    return setmetatable({ x = x, y = y }, Vec2)
end

function Vec2.__add(a, b) return Vec2.new(a.x + b.x, a.y + b.y) end
function Vec2.__mul(a, s) return Vec2.new(a.x * s, a.y * s) end
function Vec2.__tostring(v) return string.format("(%g, %g)", v.x, v.y) end
function Vec2:length() return math.sqrt(self.x^2 + self.y^2) end
```

## Coroutines

```lua
-- Producer-consumer with coroutines
local function producer(items)
    return coroutine.create(function()
        for _, item in ipairs(items) do
            coroutine.yield(item)
        end
    end)
end

local function consumer(prod)
    while true do
        local ok, value = coroutine.resume(prod)
        if not ok or value == nil then break end
        print("Got: " .. tostring(value))
    end
end

-- Iterator using coroutines
local function range(start, stop, step)
    step = step or 1
    return coroutine.wrap(function()
        local i = start
        while i <= stop do
            coroutine.yield(i)
            i = i + step
        end
    end)
end

for i in range(1, 10, 2) do
    print(i)  -- 1, 3, 5, 7, 9
end

-- State machine with coroutines
local function traffic_light()
    while true do
        coroutine.yield("green", 30)
        coroutine.yield("yellow", 5)
        coroutine.yield("red", 20)
    end
end
```

## Environments and Sandboxing

```lua
-- Sandboxed execution — restrict available functions
local function create_sandbox()
    local env = {
        print = print,
        tostring = tostring,
        tonumber = tonumber,
        type = type,
        pairs = pairs,
        ipairs = ipairs,
        math = { abs = math.abs, floor = math.floor, max = math.max, min = math.min },
        string = { format = string.format, len = string.len },
        table = { insert = table.insert, concat = table.concat },
    }
    env._G = env
    return env
end

local function run_sandboxed(code)
    local fn, err = load(code, "sandbox", "t", create_sandbox())
    if not fn then return nil, err end
    return pcall(fn)
end
```

## Module Patterns

```lua
-- Clean module pattern
local M = {}

-- Private state and helpers
local cache = {}

local function validate(key)
    return type(key) == "string" and #key > 0
end

-- Public API
function M.get(key)
    if not validate(key) then return nil, "invalid key" end
    return cache[key]
end

function M.set(key, value)
    if not validate(key) then return nil, "invalid key" end
    cache[key] = value
    return true
end

function M.clear()
    cache = {}
end

return M
```

## LuaJIT FFI

```lua
-- LuaJIT FFI for calling C functions directly
local ffi = require("ffi")

ffi.cdef[[
    typedef struct { double x, y; } Point;
    double sqrt(double x);
    int printf(const char *fmt, ...);
    void *malloc(size_t size);
    void free(void *ptr);
]]

-- Use C structs directly
local p = ffi.new("Point", { x = 3.0, y = 4.0 })
local dist = ffi.C.sqrt(p.x^2 + p.y^2)

-- Load shared libraries
local curl = ffi.load("curl")
ffi.cdef[[
    typedef void CURL;
    CURL *curl_easy_init();
    int curl_easy_setopt(CURL *curl, int option, ...);
    int curl_easy_perform(CURL *curl);
    void curl_easy_cleanup(CURL *curl);
]]
```

## Performance

```lua
-- Localize frequently used functions (avoid global lookups)
local floor = math.floor
local insert = table.insert
local format = string.format

-- Pre-allocate tables when size is known
local function create_grid(width, height)
    local grid = {}
    for y = 1, height do
        grid[y] = {}
        for x = 1, width do
            grid[y][x] = 0
        end
    end
    return grid
end

-- String building: use table.concat, not repeated ..
local function build_csv(rows)
    local lines = {}
    for i, row in ipairs(rows) do
        lines[i] = table.concat(row, ",")
    end
    return table.concat(lines, "\n")
end

-- Avoid creating closures in hot loops
-- BAD: creates a new function each iteration
for i = 1, 1000000 do
    table.sort(data, function(a, b) return a.key < b.key end)
end
-- GOOD: define comparator once
local function by_key(a, b) return a.key < b.key end
for i = 1, 1000000 do
    table.sort(data, by_key)
end
```

## Error Handling

```lua
-- Protected calls with pcall/xpcall
local function safe_json_parse(str)
    local ok, result = pcall(json.decode, str)
    if ok then return result, nil end
    return nil, "Parse error: " .. tostring(result)
end

-- xpcall with stack trace
local function run_with_trace(fn, ...)
    local args = { ... }
    return xpcall(function() return fn(table.unpack(args)) end, debug.traceback)
end

-- Pattern: return nil, err for expected failures
local function read_config(path)
    local f, err = io.open(path, "r")
    if not f then return nil, "Cannot open " .. path .. ": " .. err end
    local content = f:read("*a")
    f:close()
    local ok, data = pcall(json.decode, content)
    if not ok then return nil, "Invalid JSON in " .. path end
    return data
end
```

## Testing with Busted

```lua
describe("Vec2", function()
    it("adds vectors", function()
        local a = Vec2.new(1, 2)
        local b = Vec2.new(3, 4)
        local c = a + b
        assert.are.equal(4, c.x)
        assert.are.equal(6, c.y)
    end)

    it("calculates length", function()
        local v = Vec2.new(3, 4)
        assert.is.near(5, v:length(), 1e-10)
    end)

    it("handles errors gracefully", function()
        assert.has.errors(function() error("boom") end)
    end)
end)
```
