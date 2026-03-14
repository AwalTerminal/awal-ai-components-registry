# Flutter Patterns

## Widget Composition

Prefer composition over inheritance. Build complex UIs by combining small, focused widgets.

```dart
// BAD: Inheritance-based reuse
class MyButton extends ElevatedButton { ... }

// GOOD: Composition-based reuse
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 48),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Text(label),
    );
  }
}
```

Use builder patterns for widgets that depend on context or constraints:

```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget Function(BuildContext, BoxConstraints) builder;

  const ResponsiveLayout({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => builder(context, constraints),
    );
  }
}
```

## State Management

### Riverpod (Recommended)

Use `ref.watch` in build methods, `ref.read` in callbacks:

```dart
// Define providers outside of widgets
final userProvider = FutureProvider<User>((ref) async {
  final repo = ref.watch(userRepositoryProvider);
  return repo.getCurrentUser();
});

// Provider with family for parameterized state
final postProvider = FutureProvider.family<Post, String>((ref, postId) async {
  final repo = ref.watch(postRepositoryProvider);
  return repo.getPost(postId);
});

// Notifier for complex mutable state
@riverpod
class CartNotifier extends _$CartNotifier {
  @override
  Cart build() => const Cart.empty();

  void addItem(Product product) {
    state = state.copyWith(
      items: [...state.items, CartItem(product: product, quantity: 1)],
    );
  }

  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }
}

// Widget consuming providers
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartNotifierProvider);
    final total = ref.watch(cartTotalProvider);

    return Scaffold(
      body: ListView.builder(
        itemCount: cart.items.length,
        itemBuilder: (context, index) => CartItemTile(item: cart.items[index]),
      ),
      bottomSheet: CheckoutBar(
        total: total,
        // Use ref.read in callbacks, never ref.watch
        onCheckout: () => ref.read(cartNotifierProvider.notifier).checkout(),
      ),
    );
  }
}
```

### Bloc Pattern

Use Bloc for event-driven state with clear audit trails:

```dart
// Events
sealed class AuthEvent {}
class LoginRequested extends AuthEvent {
  final String email;
  final String password;
  LoginRequested({required this.email, required this.password});
}
class LogoutRequested extends AuthEvent {}

// States
sealed class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final User user;
  AuthAuthenticated(this.user);
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepo;

  AuthBloc(this._authRepo) : super(AuthInitial()) {
    on<LoginRequested>(_onLogin);
    on<LogoutRequested>(_onLogout);
  }

  Future<void> _onLogin(LoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepo.login(event.email, event.password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await _authRepo.logout();
    emit(AuthInitial());
  }
}
```

## Navigation

### GoRouter

Define typed routes with proper redirect logic:

```dart
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) return '/login';
      if (isLoggedIn && isLoginRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'profile/:userId',
            builder: (context, state) {
              final userId = state.pathParameters['userId']!;
              return ProfileScreen(userId: userId);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
    ],
  );
});
```

## Performance

### Minimize Rebuilds

```dart
// Use const constructors to prevent unnecessary rebuilds
class MyWidget extends StatelessWidget {
  const MyWidget({super.key}); // const constructor

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Header(),        // const prevents rebuild when parent rebuilds
        Divider(),
      ],
    );
  }
}

// Use RepaintBoundary to isolate expensive painting
RepaintBoundary(
  child: CustomPaint(
    painter: ExpensiveChartPainter(data),
  ),
)

// Use keys to preserve state correctly in lists
ListView.builder(
  itemCount: items.length,
  itemBuilder: (context, index) => ItemCard(
    key: ValueKey(items[index].id), // NOT index
    item: items[index],
  ),
)
```

### Lazy Loading and Isolates

```dart
// Offload heavy computation to isolates
Future<List<ProcessedItem>> processItems(List<RawItem> items) async {
  return compute(_processInIsolate, items);
}

List<ProcessedItem> _processInIsolate(List<RawItem> items) {
  return items.map((item) => ProcessedItem.fromRaw(item)).toList();
}

// Cached network images
CachedNetworkImage(
  imageUrl: url,
  placeholder: (context, url) => const Shimmer(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: 300, // decode at display size, not full resolution
)
```

## Architecture

### Feature-First Structure

```
lib/
  core/
    network/         # Dio client, interceptors
    storage/         # SharedPreferences, Hive wrappers
    theme/           # AppTheme, colors, typography
    utils/           # Extensions, helpers
  features/
    auth/
      data/
        models/      # UserModel (serialization)
        sources/     # AuthRemoteSource, AuthLocalSource
        repos/       # AuthRepositoryImpl
      domain/
        entities/    # User (plain object)
        repos/       # AuthRepository (abstract)
        usecases/    # LoginUseCase, LogoutUseCase
      presentation/
        providers/   # authProvider, loginProvider
        screens/     # LoginScreen, RegisterScreen
        widgets/     # LoginForm, SocialLoginButtons
    home/
      ...
  app.dart           # MaterialApp.router root
  main.dart          # Bootstrap, provider scope
```

### Repository Pattern

```dart
// Domain layer: abstract contract
abstract class ProductRepository {
  Future<List<Product>> getProducts({int page = 1, int limit = 20});
  Future<Product> getProduct(String id);
  Future<void> saveProduct(Product product);
}

// Data layer: concrete implementation
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteSource _remote;
  final ProductLocalSource _local;

  ProductRepositoryImpl(this._remote, this._local);

  @override
  Future<List<Product>> getProducts({int page = 1, int limit = 20}) async {
    try {
      final models = await _remote.fetchProducts(page: page, limit: limit);
      await _local.cacheProducts(models);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      final cached = await _local.getCachedProducts();
      if (cached.isNotEmpty) return cached.map((m) => m.toEntity()).toList();
      rethrow;
    }
  }
}
```

## Testing

### Widget Tests

```dart
testWidgets('LoginForm shows error on invalid email', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: Scaffold(body: LoginForm())),
  );

  await tester.enterText(find.byType(TextField).first, 'not-an-email');
  await tester.tap(find.text('Login'));
  await tester.pump(); // trigger rebuild

  expect(find.text('Invalid email address'), findsOneWidget);
});
```

### Golden Tests

```dart
testWidgets('ProductCard matches golden', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: ProductCard(
          product: Product(name: 'Widget', price: 9.99),
        ),
      ),
    ),
  );

  await expectLater(
    find.byType(ProductCard),
    matchesGoldenFile('goldens/product_card.png'),
  );
});
```

### Integration Tests with Riverpod

```dart
testWidgets('Cart flow: add and remove item', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        productRepositoryProvider.overrideWithValue(MockProductRepo()),
      ],
      child: const MyApp(),
    ),
  );

  await tester.pumpAndSettle(); // wait for async providers
  await tester.tap(find.text('Add to Cart'));
  await tester.pump();
  expect(find.text('1 item'), findsOneWidget);

  await tester.tap(find.byIcon(Icons.delete));
  await tester.pump();
  expect(find.text('Cart is empty'), findsOneWidget);
});
```

## Platform Channels

Keep platform-specific code behind a service interface:

```dart
// Abstract service
abstract class BiometricService {
  Future<bool> authenticate();
}

// Implementation using method channel
class BiometricServiceImpl implements BiometricService {
  static const _channel = MethodChannel('com.app/biometric');

  @override
  Future<bool> authenticate() async {
    try {
      final result = await _channel.invokeMethod<bool>('authenticate');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }
}
```
