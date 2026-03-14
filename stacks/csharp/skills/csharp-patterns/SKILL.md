# C# Patterns

## LINQ Mastery

```csharp
// Method syntax — preferred for complex queries
var topCustomers = orders
    .Where(o => o.Status == OrderStatus.Completed)
    .GroupBy(o => o.CustomerId)
    .Select(g => new {
        CustomerId = g.Key,
        Total = g.Sum(o => o.Amount),
        Count = g.Count()
    })
    .OrderByDescending(x => x.Total)
    .Take(10)
    .ToList();

// Query syntax — useful for joins
var report = from o in orders
             join c in customers on o.CustomerId equals c.Id
             where o.Date >= cutoff
             group o by c.Name into g
             select new { Customer = g.Key, Revenue = g.Sum(o => o.Amount) };

// Deferred execution — query runs only when enumerated
IQueryable<Order> query = db.Orders.Where(o => o.Total > 100);
// No SQL executed yet — add more filters
query = query.Where(o => o.Date > DateTime.UtcNow.AddDays(-30));
var results = await query.ToListAsync(); // SQL executes here
```

## Async/Await Patterns

```csharp
// Standard async method
public async Task<Order> GetOrderAsync(int id, CancellationToken ct = default)
{
    var order = await _db.Orders
        .Include(o => o.Items)
        .FirstOrDefaultAsync(o => o.Id == id, ct)
        ?? throw new NotFoundException($"Order {id} not found");

    return order;
}

// ValueTask for hot paths that often complete synchronously
public ValueTask<CacheEntry> GetCachedAsync(string key)
{
    if (_cache.TryGetValue(key, out var entry))
        return ValueTask.FromResult(entry);

    return new ValueTask<CacheEntry>(LoadFromSourceAsync(key));
}

// IAsyncEnumerable for streaming results
public async IAsyncEnumerable<LogEntry> StreamLogsAsync(
    [EnumeratorCancellation] CancellationToken ct = default)
{
    await foreach (var batch in _source.ReadBatchesAsync(ct))
    {
        foreach (var entry in batch)
            yield return entry;
    }
}

// Parallel async with controlled concurrency
public async Task ProcessAllAsync(IEnumerable<Item> items)
{
    var semaphore = new SemaphoreSlim(10);
    var tasks = items.Select(async item =>
    {
        await semaphore.WaitAsync();
        try { await ProcessItemAsync(item); }
        finally { semaphore.Release(); }
    });
    await Task.WhenAll(tasks);
}
```

## Records and Pattern Matching

```csharp
// Records — immutable by default, value equality
public record Money(decimal Amount, string Currency)
{
    public Money Add(Money other) =>
        Currency == other.Currency
            ? this with { Amount = Amount + other.Amount }
            : throw new CurrencyMismatchException();
}

// Record structs for allocation-free value types
public readonly record struct Point(double X, double Y);

// Pattern matching
public decimal CalculateDiscount(Customer customer) => customer switch
{
    { Tier: "gold", YearsActive: > 5 } => 0.25m,
    { Tier: "gold" } => 0.15m,
    { Tier: "silver" } => 0.10m,
    { OrderCount: > 100 } => 0.05m,
    _ => 0m
};

// List patterns (C# 11)
int[] numbers = [1, 2, 3, 4, 5];
var result = numbers switch
{
    [1, .., > 4] => "starts with 1, ends above 4",
    [_, _, 3, ..] => "third element is 3",
    { Length: 0 } => "empty",
    _ => "other"
};
```

## Nullable Reference Types

```csharp
// Enable in .csproj: <Nullable>enable</Nullable>
public class UserService
{
    // Non-nullable — compiler ensures this is never null
    public User GetUser(int id) =>
        _repo.Find(id) ?? throw new NotFoundException();

    // Nullable — caller must handle null
    public User? FindUser(string email) =>
        _repo.FindByEmail(email);

    // Null-forgiving for tests/deserialization where you know better
    private readonly ILogger _logger = null!; // Set by DI
}
```

## Span<T> and Memory Performance

```csharp
// Stack-allocated parsing — zero heap allocations
public static bool TryParseHeader(ReadOnlySpan<char> line, out ReadOnlySpan<char> key, out ReadOnlySpan<char> value)
{
    var separator = line.IndexOf(':');
    if (separator < 0)
    {
        key = default;
        value = default;
        return false;
    }
    key = line[..separator].Trim();
    value = line[(separator + 1)..].Trim();
    return true;
}

// ArrayPool to avoid GC pressure
public void ProcessLargeData(Stream stream)
{
    var buffer = ArrayPool<byte>.Shared.Rent(8192);
    try
    {
        int bytesRead;
        while ((bytesRead = stream.Read(buffer, 0, buffer.Length)) > 0)
            Process(buffer.AsSpan(0, bytesRead));
    }
    finally
    {
        ArrayPool<byte>.Shared.Return(buffer);
    }
}
```

## Dependency Injection (.NET)

```csharp
// Program.cs — service registration
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddScoped<IOrderRepository, SqlOrderRepository>();
builder.Services.AddSingleton<ICacheService, RedisCacheService>();
builder.Services.AddTransient<IEmailSender, SmtpEmailSender>();
builder.Services.Configure<StripeOptions>(builder.Configuration.GetSection("Stripe"));

// Options pattern
public class StripeOptions
{
    public string ApiKey { get; init; } = "";
    public string WebhookSecret { get; init; } = "";
}

public class PaymentService(IOptions<StripeOptions> options)
{
    private readonly string _apiKey = options.Value.ApiKey;
}
```

## Entity Framework Patterns

- Use `AsNoTracking()` for all read-only queries
- Use `.Include()` for eager loading — avoid lazy loading
- Use `IQueryable<T>` to compose filters before execution
- Keep `DbContext` lifetime scoped (one per request)
- Use migrations for all schema changes: `dotnet ef migrations add <Name>`

## Testing

### xUnit with FluentAssertions

```csharp
public class OrderServiceTests
{
    private readonly Mock<IOrderRepository> _repoMock = new();
    private readonly OrderService _sut;

    public OrderServiceTests()
    {
        _sut = new OrderService(_repoMock.Object);
    }

    [Fact]
    public async Task CreateOrder_WithValidData_ReturnsOrder()
    {
        _repoMock.Setup(r => r.SaveAsync(It.IsAny<Order>(), default))
            .ReturnsAsync((Order o, CancellationToken _) => o);

        var order = await _sut.CreateOrderAsync(new CreateOrderDto("item", 100));

        order.Should().NotBeNull();
        order.Total.Should().Be(100);
        order.Status.Should().Be(OrderStatus.Pending);
        _repoMock.Verify(r => r.SaveAsync(It.IsAny<Order>(), default), Times.Once);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(-1)]
    public async Task CreateOrder_WithInvalidAmount_ThrowsValidation(decimal amount)
    {
        var act = () => _sut.CreateOrderAsync(new CreateOrderDto("item", amount));

        await act.Should().ThrowAsync<ValidationException>()
            .WithMessage("*amount*");
    }
}
```

## Performance Checklist

- Prefer `struct` over `class` for small, short-lived value types (under 16 bytes)
- Use `stackalloc` for small temporary buffers: `Span<byte> buf = stackalloc byte[256]`
- Use `ArrayPool<T>.Shared` for larger temporary arrays
- Use `ValueTask` over `Task` when the common path is synchronous
- Profile with `BenchmarkDotNet` before and after optimization

## Primary Constructor Patterns (C# 12)

```csharp
// Primary constructors on classes — DI-friendly
public class OrderService(IOrderRepository repo, ILogger<OrderService> logger)
{
    public async Task<Order> GetOrderAsync(int id)
    {
        logger.LogInformation("Fetching order {Id}", id);
        return await repo.FindAsync(id)
            ?? throw new NotFoundException($"Order {id} not found");
    }
}

// Capture parameters in fields when needed outside methods
public class CacheService(IMemoryCache cache, TimeSpan defaultExpiry)
{
    private readonly TimeSpan _expiry = defaultExpiry;

    public T GetOrCreate<T>(string key, Func<T> factory) =>
        cache.GetOrCreate(key, entry =>
        {
            entry.AbsoluteExpirationRelativeToNow = _expiry;
            return factory();
        })!;
}

// Combine with interfaces for testable services
public class NotificationService(IEmailSender email, ILogger<NotificationService> logger)
    : INotificationService
{
    public async Task NotifyAsync(string userId, string message)
    {
        logger.LogInformation("Notifying {UserId}", userId);
        await email.SendAsync(userId, "Notification", message);
    }
}
```
