# Angular Patterns

## Signals

Signals are the preferred reactive primitive for component-level state in Angular 17+:

```typescript
import { signal, computed, effect } from '@angular/core';

@Component({
  selector: 'app-counter',
  standalone: true,
  template: `
    <p>Count: {{ count() }}</p>
    <p>Double: {{ double() }}</p>
    <button (click)="increment()">+</button>
    <button (click)="reset()">Reset</button>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class CounterComponent {
  count = signal(0);
  double = computed(() => this.count() * 2);

  constructor() {
    // effect runs when any signal it reads changes
    effect(() => {
      console.log(`Count changed to ${this.count()}`);
    });
  }

  increment() {
    this.count.update(c => c + 1);
  }

  reset() {
    this.count.set(0);
  }
}
```

### Signal-Based Inputs and Outputs

```typescript
@Component({
  selector: 'app-user-card',
  standalone: true,
  template: `
    <div class="card" (click)="selected.emit(user().id)">
      <h3>{{ user().name }}</h3>
      <span [class.highlight]="isActive()">{{ user().role }}</span>
    </div>
  `,
})
export class UserCardComponent {
  user = input.required<User>();
  highlightRole = input<string>('admin');
  selected = output<string>();

  isActive = computed(() => this.user().role === this.highlightRole());
}
```

### Bridging RxJS and Signals

```typescript
@Component({ ... })
export class SearchComponent {
  private searchService = inject(SearchService);

  query = signal('');

  // Convert observable to signal
  results = toSignal(
    toObservable(this.query).pipe(
      debounceTime(300),
      filter(q => q.length >= 2),
      switchMap(q => this.searchService.search(q)),
    ),
    { initialValue: [] },
  );
}
```

## Standalone Components

All new components should be standalone. Import dependencies directly:

```typescript
@Component({
  selector: 'app-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    RouterLink,
    MatCardModule,
    MatButtonModule,
    StatsChartComponent,
    RecentActivityComponent,
  ],
  template: `
    @if (loading()) {
      <app-skeleton />
    } @else {
      <div class="grid">
        @for (stat of stats(); track stat.id) {
          <mat-card>
            <mat-card-header>{{ stat.label }}</mat-card-header>
            <mat-card-content>
              <app-stats-chart [data]="stat.data" />
            </mat-card-content>
          </mat-card>
        } @empty {
          <p>No statistics available</p>
        }
      </div>
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class DashboardComponent {
  private dashboardService = inject(DashboardService);

  loading = signal(true);
  stats = signal<Stat[]>([]);

  constructor() {
    this.dashboardService.getStats().subscribe(data => {
      this.stats.set(data);
      this.loading.set(false);
    });
  }
}
```

## Dependency Injection

### inject() Function

Prefer the `inject()` function over constructor injection for cleaner code:

```typescript
@Injectable({ providedIn: 'root' })
export class AuthService {
  private http = inject(HttpClient);
  private router = inject(Router);

  private userSubject = new BehaviorSubject<User | null>(null);
  user$ = this.userSubject.asObservable();

  login(credentials: LoginRequest): Observable<User> {
    return this.http.post<AuthResponse>('/api/auth/login', credentials).pipe(
      tap(response => {
        localStorage.setItem('token', response.token);
        this.userSubject.next(response.user);
      }),
      map(response => response.user),
    );
  }

  logout() {
    localStorage.removeItem('token');
    this.userSubject.next(null);
    this.router.navigate(['/login']);
  }
}
```

### Custom Injection Tokens

```typescript
export const API_BASE_URL = new InjectionToken<string>('API_BASE_URL');
export const FEATURE_FLAGS = new InjectionToken<FeatureFlags>('FEATURE_FLAGS');

// Provide at app level
bootstrapApplication(AppComponent, {
  providers: [
    { provide: API_BASE_URL, useValue: environment.apiUrl },
    {
      provide: FEATURE_FLAGS,
      useFactory: () => {
        const http = inject(HttpClient);
        return lastValueFrom(http.get<FeatureFlags>('/api/flags'));
      },
    },
  ],
});

// Consume anywhere
@Injectable({ providedIn: 'root' })
export class ApiService {
  private baseUrl = inject(API_BASE_URL);
}
```

## RxJS Patterns

### Avoiding Nested Subscribes

```typescript
// BAD: nested subscribes
this.route.params.subscribe(params => {
  this.userService.getUser(params['id']).subscribe(user => {
    this.postService.getPosts(user.id).subscribe(posts => {
      this.posts = posts;
    });
  });
});

// GOOD: flattened with operators
this.route.params.pipe(
  map(params => params['id']),
  switchMap(id => this.userService.getUser(id)),
  switchMap(user => this.postService.getPosts(user.id)),
  takeUntilDestroyed(),
).subscribe(posts => this.posts.set(posts));
```

### Choosing the Right Flattening Operator

- `switchMap`: cancel previous inner observable (search, navigation, HTTP reads)
- `concatMap`: queue inner observables in order (form submissions, writes)
- `mergeMap`: run all inner observables concurrently (parallel downloads)
- `exhaustMap`: ignore new emissions while inner is active (login button)

```typescript
// exhaustMap: prevent double-submit
onSubmit$ = new Subject<FormData>();

result$ = this.onSubmit$.pipe(
  exhaustMap(data => this.http.post('/api/submit', data)),
);
```

### Proper Cleanup

```typescript
@Component({ ... })
export class LiveDataComponent {
  private destroy = inject(DestroyRef);

  constructor() {
    this.dataService.liveUpdates$.pipe(
      takeUntilDestroyed(this.destroy),
    ).subscribe(update => this.data.set(update));
  }
}
```

## Forms

### Reactive Forms with Typed Controls

```typescript
@Component({
  standalone: true,
  imports: [ReactiveFormsModule],
  template: `
    <form [formGroup]="form" (ngSubmit)="onSubmit()">
      <input formControlName="email" />
      @if (form.controls.email.errors?.['email']) {
        <span class="error">Invalid email</span>
      }
      <input formControlName="password" type="password" />
      <button [disabled]="form.invalid || submitting()">Submit</button>
    </form>
  `,
})
export class LoginFormComponent {
  private fb = inject(NonNullableFormBuilder);
  private auth = inject(AuthService);

  submitting = signal(false);

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(8)]],
  });

  onSubmit() {
    if (this.form.invalid) return;
    this.submitting.set(true);
    const { email, password } = this.form.getRawValue();
    this.auth.login({ email, password }).subscribe({
      next: () => this.submitting.set(false),
      error: () => this.submitting.set(false),
    });
  }
}
```

## Architecture

### Feature-Based Structure

```
src/app/
  core/
    interceptors/    # HTTP interceptors (auth token, error handling)
    guards/          # Route guards
    services/        # Singleton services (AuthService, ApiService)
  shared/
    components/      # Reusable UI components (Button, Modal, Table)
    directives/      # Custom directives
    pipes/           # Custom pipes
  features/
    dashboard/
      dashboard.component.ts
      dashboard.routes.ts
      components/    # Feature-specific sub-components
      services/      # Feature-scoped services
    auth/
      login.component.ts
      register.component.ts
      auth.routes.ts
      auth.service.ts
  app.routes.ts
  app.component.ts
  app.config.ts
```

### Lazy Loading Routes

```typescript
// app.routes.ts
export const routes: Routes = [
  { path: '', redirectTo: 'dashboard', pathMatch: 'full' },
  {
    path: 'dashboard',
    loadComponent: () =>
      import('./features/dashboard/dashboard.component').then(
        m => m.DashboardComponent,
      ),
  },
  {
    path: 'admin',
    canActivate: [() => inject(AuthService).isAdmin()],
    loadChildren: () =>
      import('./features/admin/admin.routes').then(m => m.ADMIN_ROUTES),
  },
];
```

### Smart / Dumb Component Pattern

```typescript
// Smart (container): handles data and logic
@Component({
  standalone: true,
  imports: [UserListComponent],
  template: `
    <app-user-list
      [users]="users()"
      [loading]="loading()"
      (userSelected)="onUserSelected($event)"
      (userDeleted)="onUserDeleted($event)"
    />
  `,
})
export class UserPageComponent {
  private userService = inject(UserService);
  users = signal<User[]>([]);
  loading = signal(true);

  constructor() {
    this.userService.getAll().subscribe(users => {
      this.users.set(users);
      this.loading.set(false);
    });
  }

  onUserSelected(userId: string) { ... }
  onUserDeleted(userId: string) { ... }
}

// Dumb (presentational): pure inputs/outputs, no injected services
@Component({
  standalone: true,
  selector: 'app-user-list',
  template: `
    @if (loading()) {
      <app-skeleton-list />
    } @else {
      @for (user of users(); track user.id) {
        <app-user-card
          [user]="user"
          (click)="userSelected.emit(user.id)"
          (delete)="userDeleted.emit(user.id)"
        />
      }
    }
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
})
export class UserListComponent {
  users = input.required<User[]>();
  loading = input(false);
  userSelected = output<string>();
  userDeleted = output<string>();
}
```

## Performance

### OnPush Change Detection

Always use `OnPush`. With signals and immutable data, Angular only checks components when:
- An input signal changes
- An event handler fires within the component
- An observable piped through `async` emits

### trackBy in @for

```html
<!-- track is mandatory in @for -- choose a stable unique identifier -->
@for (item of items(); track item.id) {
  <app-item-row [item]="item" />
}
```

## Testing

### Component Tests with TestBed

```typescript
describe('LoginFormComponent', () => {
  let component: LoginFormComponent;
  let fixture: ComponentFixture<LoginFormComponent>;
  let authService: jasmine.SpyObj<AuthService>;

  beforeEach(async () => {
    authService = jasmine.createSpyObj('AuthService', ['login']);

    await TestBed.configureTestingModule({
      imports: [LoginFormComponent],
      providers: [{ provide: AuthService, useValue: authService }],
    }).compileComponents();

    fixture = TestBed.createComponent(LoginFormComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('disables submit when form is invalid', () => {
    const button = fixture.nativeElement.querySelector('button');
    expect(button.disabled).toBeTrue();
  });

  it('calls auth service on valid submit', () => {
    authService.login.and.returnValue(of({ id: '1', name: 'Test' }));

    component.form.setValue({ email: 'a@b.com', password: '12345678' });
    component.onSubmit();

    expect(authService.login).toHaveBeenCalledWith({
      email: 'a@b.com',
      password: '12345678',
    });
  });
});
```

### Testing with Spectator

```typescript
import { createComponentFactory, Spectator } from '@ngneat/spectator';

describe('SearchComponent', () => {
  let spectator: Spectator<SearchComponent>;
  const createComponent = createComponentFactory({
    component: SearchComponent,
    mocks: [SearchService],
  });

  beforeEach(() => (spectator = createComponent()));

  it('shows results after typing', async () => {
    const service = spectator.inject(SearchService);
    service.search.and.returnValue(of([{ name: 'Result 1' }]));

    spectator.typeInElement('query', 'input');
    spectator.tick(300); // debounce

    expect(spectator.queryAll('.result-item')).toHaveLength(1);
  });
});
```
