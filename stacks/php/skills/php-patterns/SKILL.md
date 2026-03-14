# PHP Patterns

## Modern PHP 8.x Features

### Enums

```php
enum Status: string {
    case Active = 'active';
    case Inactive = 'inactive';
    case Suspended = 'suspended';

    public function label(): string {
        return match($this) {
            self::Active => 'Active User',
            self::Inactive => 'Inactive User',
            self::Suspended => 'Account Suspended',
        };
    }

    public function canLogin(): bool {
        return $this === self::Active;
    }
}

// Usage: Status::Active->label(), Status::from('active')
```

### Readonly Classes and Properties

```php
readonly class Money {
    public function __construct(
        public int $amount,
        public string $currency,
    ) {}

    public function add(Money $other): self {
        if ($this->currency !== $other->currency) {
            throw new CurrencyMismatchException($this->currency, $other->currency);
        }
        return new self($this->amount + $other->amount, $this->currency);
    }
}
```

### Intersection Types and Named Arguments

```php
function process(Countable&Iterator $collection): void {
    foreach ($collection as $item) {
        // $collection is guaranteed to be both Countable and Iterator
    }
}

// Named arguments for clarity
$user = new User(
    name: 'Jane',
    email: 'jane@example.com',
    role: Role::Admin,
);
```

### First-Class Callables and Match

```php
$users = array_filter($users, $validator->isValid(...));
$names = array_map(strtoupper(...), $rawNames);

$result = match(true) {
    $age < 13 => 'child',
    $age < 18 => 'teenager',
    $age < 65 => 'adult',
    default   => 'senior',
};
```

## Dependency Injection and Repository Pattern

```php
interface UserRepositoryInterface {
    public function find(int $id): ?User;
    public function findByEmail(string $email): ?User;
    public function save(User $user): void;
}

final class EloquentUserRepository implements UserRepositoryInterface {
    public function find(int $id): ?User {
        return User::find($id);
    }

    public function findByEmail(string $email): ?User {
        return User::where('email', $email)->first();
    }

    public function save(User $user): void {
        $user->save();
    }
}

// Service provider binding
$this->app->bind(UserRepositoryInterface::class, EloquentUserRepository::class);
```

## PSR Standards

- PSR-4: autoloading — one class per file, namespace matches directory
- PSR-12: coding style (use PHP-CS-Fixer or PHP_CodeSniffer)
- PSR-3: `LoggerInterface` — use for all logging
- PSR-7/PSR-15: HTTP message and middleware interfaces

## Exception Hierarchy

```php
// Base domain exception
abstract class DomainException extends \RuntimeException {}

class EntityNotFoundException extends DomainException {
    public static function forClass(string $class, mixed $id): self {
        return new self(sprintf('%s with ID %s not found', $class, $id));
    }
}

class ValidationException extends DomainException {
    public function __construct(
        private readonly array $errors,
        string $message = 'Validation failed',
    ) {
        parent::__construct($message);
    }

    public function getErrors(): array {
        return $this->errors;
    }
}
```

- Never catch `\Exception` or `\Throwable` broadly — catch specific types
- Use `set_error_handler` to convert legacy warnings to exceptions
- Use `set_exception_handler` for uncaught exception logging

## Laravel and Symfony Patterns

### Service Objects

```php
final class CreateOrderAction {
    public function __construct(
        private readonly OrderRepositoryInterface $orders,
        private readonly PaymentGateway $payments,
        private readonly EventDispatcherInterface $events,
    ) {}

    public function execute(CreateOrderDTO $dto): Order {
        return DB::transaction(function () use ($dto) {
            $order = Order::create([
                'user_id' => $dto->userId,
                'total' => $dto->total,
                'status' => OrderStatus::Pending,
            ]);

            $this->payments->charge($order);
            $this->events->dispatch(new OrderCreated($order));

            return $order;
        });
    }
}
```

### Form Requests (Laravel)

```php
final class StoreUserRequest extends FormRequest {
    public function authorize(): bool {
        return $this->user()->can('create', User::class);
    }

    public function rules(): array {
        return [
            'name'  => ['required', 'string', 'max:255'],
            'email' => ['required', 'email', 'unique:users,email'],
            'role'  => ['required', Rule::enum(Role::class)],
        ];
    }
}
```

## Performance

- **OPcache**: enable in production, set `opcache.validate_timestamps=0`
- **Preloading**: use `opcache.preload` to load frequently used classes at startup
- **JIT**: enable with `opcache.jit_buffer_size=100M` for compute-heavy workloads
- **Query optimization**: use `select()` to limit columns, `chunk()` for large sets, avoid `N+1` with `with()`/`load()`
- **Caching**: use PSR-6/PSR-16 cache interfaces; cache config, routes, and views in production

## Testing

### PHPUnit

```php
final class OrderServiceTest extends TestCase {
    public function test_creates_order_with_valid_data(): void {
        $repo = $this->createMock(OrderRepositoryInterface::class);
        $repo->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Order::class));

        $service = new OrderService($repo);
        $order = $service->create(new CreateOrderDTO(userId: 1, total: 9999));

        $this->assertSame(OrderStatus::Pending, $order->status);
    }
}
```

### Pest

```php
it('creates an order with valid data', function () {
    $service = new OrderService(mock(OrderRepositoryInterface::class));
    $order = $service->create(new CreateOrderDTO(userId: 1, total: 9999));

    expect($order->status)->toBe(OrderStatus::Pending)
        ->and($order->total)->toBe(9999);
});

it('rejects negative totals', function () {
    $service = new OrderService(mock(OrderRepositoryInterface::class));
    $service->create(new CreateOrderDTO(userId: 1, total: -1));
})->throws(ValidationException::class);
```

### Mockery

```php
$gateway = Mockery::mock(PaymentGateway::class);
$gateway->shouldReceive('charge')
    ->once()
    ->with(Mockery::on(fn (Order $o) => $o->total > 0))
    ->andReturn(new PaymentResult(success: true));
```

## Security Essentials

- Always `declare(strict_types=1)` at the top of every file
- Use prepared statements via Eloquent/PDO — never concatenate SQL
- Escape output: Blade `{{ }}` or `htmlspecialchars()`
- Use `password_hash()` / `password_verify()` — never MD5/SHA1
- Validate all input with typed DTOs or Form Requests
