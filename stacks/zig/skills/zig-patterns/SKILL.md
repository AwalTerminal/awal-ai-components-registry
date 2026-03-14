# Zig Patterns

## Comptime

```zig
// Generic data structure via comptime parameters
fn HashMap(comptime K: type, comptime V: type) type {
    return struct {
        const Self = @This();
        entries: []?Entry,

        const Entry = struct {
            key: K,
            value: V,
        };

        pub fn get(self: *Self, key: K) ?V {
            // hash and lookup
            _ = self;
            _ = key;
            return null;
        }
    };
}

const StringMap = HashMap([]const u8, i32);

// Compile-time reflection with @typeInfo
fn fieldsOf(comptime T: type) []const []const u8 {
    const info = @typeInfo(T);
    switch (info) {
        .@"struct" => |s| {
            var names: [s.fields.len][]const u8 = undefined;
            for (s.fields, 0..) |field, i| {
                names[i] = field.name;
            }
            return &names;
        },
        else => @compileError("Expected a struct type"),
    }
}
```

## Error Handling

```zig
const std = @import("std");

// Error sets — enumerate exactly which errors a function can return
const FileError = error{
    FileNotFound,
    PermissionDenied,
    DiskFull,
};

// Error union return type — try propagates, catch handles
fn readConfig(path: []const u8) FileError!Config {
    const file = std.fs.cwd().openFile(path, .{}) catch |err| switch (err) {
        error.FileNotFound => return error.FileNotFound,
        error.AccessDenied => return error.PermissionDenied,
        else => return error.FileNotFound,
    };
    defer file.close();
    return Config{};
}

fn loadWithDefaults() Config {
    return readConfig("app.conf") catch Config.defaults();
}

// errdefer — cleanup only on error path
fn createResource(allocator: std.mem.Allocator) !*Resource {
    const resource = try allocator.create(Resource);
    errdefer allocator.destroy(resource);

    resource.* = .{
        .data = try allocator.alloc(u8, 1024),
    };
    errdefer allocator.free(resource.data);

    try resource.init();
    return resource;
}
```

## Allocator Patterns

```zig
const std = @import("std");

// Always accept allocator as parameter — never use globals
fn buildString(allocator: std.mem.Allocator, parts: []const []const u8) ![]u8 {
    var total: usize = 0;
    for (parts) |p| total += p.len;
    const result = try allocator.alloc(u8, total);
    var off: usize = 0;
    for (parts) |p| { @memcpy(result[off..][0..p.len], p); off += p.len; }
    return result;
}

// Arena allocator — batch allocations with shared lifetime
fn processRequest(gpa: std.mem.Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit(); // Frees everything at once
    const allocator = arena.allocator();
    try handleRequest(allocator, try parseHeaders(allocator));
}

// GeneralPurposeAllocator — debug allocator detecting leaks and use-after-free
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    try run(gpa.allocator());
}

```

## Optional Types

```zig
// Optional type — ?T is either a value or null
fn findUser(id: u64) ?User {
    for (users) |user| {
        if (user.id == id) return user;
    }
    return null;
}

// Unwrap with orelse
const user = findUser(42) orelse return error.UserNotFound;

// Optional payload capture with if
if (findUser(42)) |user| {
    std.debug.print("Found: {s}\n", .{user.name});
} else {
    std.debug.print("Not found\n", .{});
}

// Optional chaining with while
var iter = list.iterator();
while (iter.next()) |item| {
    process(item);
}
```

## Packed Structs

```zig
// Packed struct — exact memory layout for hardware/protocols
const TcpFlags = packed struct(u8) {
    fin: bool,
    syn: bool,
    rst: bool,
    psh: bool,
    ack: bool,
    urg: bool,
    _reserved: u2 = 0,
};

const flags: TcpFlags = @bitCast(@as(u8, 0x12)); // SYN + ACK
// Use extern struct for C ABI compatibility
```

## C Interop

```zig
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
});

fn printWithC(msg: [*:0]const u8) void {
    _ = c.printf("Message: %s\n", msg);
}

// In build.zig: exe.linkSystemLibrary("sqlite3"); exe.linkLibC();
```

## Testing

```zig
const std = @import("std");
const testing = std.testing;

test "basic arithmetic" {
    const result = add(2, 3);
    try testing.expectEqual(@as(i32, 5), result);
}

test "string operations" {
    const allocator = testing.allocator; // Detects leaks automatically
    const s = try std.fmt.allocPrint(allocator, "hello {s}", .{"world"});
    defer allocator.free(s);

    try testing.expectEqualStrings("hello world", s);
}

test "error handling" {
    try testing.expectError(error.InvalidInput, riskyFunction());
}
// testing.allocator auto-detects leaks — any unfreed memory fails the test
```

## Build System (build.zig)

```zig
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "myapp",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    exe.linkSystemLibrary("sqlite3");
    exe.linkLibC();
    b.installArtifact(exe);

    b.step("run", "Run the app").dependOn(&b.addRunArtifact(exe).step);
    b.step("test", "Run tests").dependOn(&b.addRunArtifact(b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target, .optimize = optimize,
    })).step);
}
```

## Concurrency

```zig
// Mutex for shared state
const SharedCounter = struct {
    mutex: std.Thread.Mutex = .{},
    value: usize = 0,

    fn increment(self: *SharedCounter) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.value += 1;
    }
};

// Atomics for lock-free operations
var count = std.atomic.Value(usize).init(0);
_ = count.fetchAdd(1, .monotonic);
```

## Performance Tips

- Use `@Vector` for SIMD operations on fixed-size arrays
- Use `comptime` to move computation to compile time when inputs are known
- Prefer slices over pointer arithmetic
- Profile with `-Doptimize=ReleaseFast` for production, `Debug` for development
