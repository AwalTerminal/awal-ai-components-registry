# Clean Code Rules

## Complexity Thresholds

These are hard limits. Code exceeding them must be refactored before merge:

| Metric | Limit | Action when exceeded |
|---|---|---|
| Cyclomatic complexity | ≤ 10 per function | Extract branches into named functions |
| Function length | ≤ 40 lines | Split by responsibility |
| Parameter count | ≤ 4 per function | Introduce parameter object or builder |
| Nesting depth | ≤ 3 levels | Use guard clauses or extract helper |
| File length | ≤ 400 lines | Split into modules by cohesion |

## Naming Conventions

| Element | Convention | Examples |
|---|---|---|
| Types / Classes | PascalCase, noun phrase | `UserAccount`, `HttpResponse`, `OrderValidator` |
| Functions / Methods | camelCase or snake_case (match lang), verb phrase | `calculateTotal`, `send_notification` |
| Booleans | Prefix with `is`, `has`, `can`, `should`, `was` | `isActive`, `hasPermission`, `canRetry` |
| Collections | Plural nouns | `users`, `pendingOrders`, `error_messages` |
| Constants | UPPER_SNAKE_CASE | `MAX_RETRY_COUNT`, `DEFAULT_TIMEOUT_MS` |
| Private fields | Prefix with `_` (if lang convention) | `_cache`, `_connectionPool` |
| Interfaces | Adjective or capability noun | `Serializable`, `EventHandler`, `Comparable` |

### Naming — Before/After

```
# BAD
def proc(d, f):
    r = []
    for i in d:
        if f(i):
            r.append(i)
    return r

# GOOD
def filter_matching(items, predicate):
    matches = []
    for item in items:
        if predicate(item):
            matches.append(item)
    return matches
```

```
# BAD
const data = fetchData();     // "data" says nothing about what it is
const flag = true;            // "flag" for what?
const temp = process(input);  // "temp" has no meaning

# GOOD
const activeUsers = fetchActiveUsers();
const isRetryEnabled = true;
const normalizedAddress = normalizeAddress(rawAddress);
```

## Function Design

### Guard Clauses and Early Returns

Prefer guard clauses at the top of a function to eliminate nesting. A function should handle edge cases first, then express the main logic at the base indentation level.

```
# BAD — deeply nested
def process_order(order):
    if order is not None:
        if order.is_valid():
            if order.has_items():
                # 20 lines of actual logic at 4 levels deep
                ...

# GOOD — guard clauses
def process_order(order):
    if order is None:
        raise ValueError("Order cannot be None")
    if not order.is_valid():
        raise InvalidOrderError(order.id)
    if not order.has_items():
        return EmptyOrderResult()

    # main logic at base indentation
    ...
```

### Single Responsibility

Each function does exactly one thing. If you need an `and` to describe what it does, split it.

```
# BAD — does two things
def validate_and_save_user(user):
    if not user.email:
        raise ValidationError("email required")
    db.save(user)

# GOOD — separate concerns
def validate_user(user):
    if not user.email:
        raise ValidationError("email required")

def save_user(user):
    validate_user(user)
    db.save(user)
```

### Parameter Objects

When a function needs more than 4 parameters, group them:

```
# BAD
def send_email(to, from_addr, subject, body, cc, bcc, reply_to, priority):
    ...

# GOOD
@dataclass
class EmailMessage:
    to: str
    from_addr: str
    subject: str
    body: str
    cc: str | None = None
    bcc: str | None = None
    reply_to: str | None = None
    priority: str = "normal"

def send_email(message: EmailMessage):
    ...
```

## DRY vs. WET (Write Everything Twice)

**DRY is not about eliminating textual duplication — it is about eliminating knowledge duplication.**

Prefer duplication over the wrong abstraction. Apply the Rule of Three:

1. **First occurrence** — just write it.
2. **Second occurrence** — note it, leave it duplicated.
3. **Third occurrence** — now extract a shared abstraction.

### When duplication IS better than abstraction

- Two functions look similar but serve different business domains and will diverge over time.
- Shared code requires parameters like `isSpecialCase` or `mode` flags to handle each caller — this is a sign the abstraction is forced.
- Test setup code: duplicated test fixtures are clearer than deeply shared test helpers that obscure what each test actually needs.

### When to extract

- Three or more call sites with truly identical logic and identical reasons to change.
- A bug fix in one copy would always need the same fix in the others.

## Magic Numbers and Constants

Never embed unexplained numeric or string literals in logic.

```
# BAD
if retries > 3:
    sleep(86400)

# GOOD
MAX_RETRIES = 3
RETRY_BACKOFF_SECONDS = 86_400  # 24 hours

if retries > MAX_RETRIES:
    sleep(RETRY_BACKOFF_SECONDS)
```

Exceptions: `0`, `1`, `-1` as identity values, empty strings, and universally obvious values like `100` for percentage denominators.

## Comment Policy

### Good Comments (keep these)

```python
# We retry 3 times because the upstream payment API returns transient 503s
# under load; see incident report INC-2084.
MAX_RETRIES = 3

# HACK: The vendor SDK mutates global state, so we must lock here.
# Remove after upgrading to vendor-sdk >= 4.0.
with global_lock:
    vendor.initialize()
```

### Bad Comments (delete or rewrite the code)

```python
# Increment counter
counter += 1                    # obvious — delete

# Check if user is admin
if user.role == "admin":        # restates the code — delete

# TODO
# (empty TODO with no context)  # useless — delete or describe the work

# This function gets users
def get_users():                # name already says this — delete
```

### Rules

- Comment **why**, never **what** (the code already says what).
- Every TODO must have a description and ideally a ticket ID: `# TODO(JIRA-123): migrate to new auth endpoint`.
- Delete commented-out code. Version control remembers it.
- If a comment is needed to explain complex logic, first try to simplify the logic or extract a well-named function.

## Dead Code

- Delete unused functions, unreachable branches, and commented-out blocks.
- Do not keep code "in case we need it later" — retrieve it from version history.
- Detect dead code by searching for functions with zero call sites (excluding public API entry points and framework hooks).
- Unused imports, variables, and parameters should be removed. If a parameter must exist for interface compliance, prefix with `_`.

## Anti-Patterns and Code Smells

| Smell | Indicator | Fix |
|---|---|---|
| **God function** | > 40 lines or cyclomatic complexity > 10 | Extract methods by responsibility |
| **Feature envy** | Function accesses another object's fields more than its own | Move the function to the object it envies |
| **Primitive obsession** | Passing `(street, city, zip, country)` instead of `Address` | Introduce a value object |
| **Boolean blindness** | `process(data, true, false, true)` | Use named constants, enums, or a config object |
| **Shotgun surgery** | One change requires edits in 5+ files | Consolidate related logic into a single module |
| **Long parameter list** | > 4 params | Parameter object or builder |
| **Speculative generality** | Interfaces with one implementation, unused hooks | Delete it; add abstraction when a second consumer exists |
| **Middle man** | Class that only delegates to another | Inline the delegation |

## Module and File Organization

- One primary type or concept per file. A file named `order.py` exports `Order` and closely related helpers, not `User`.
- Group files by feature or domain, not by technical layer (prefer `orders/repository.py` over `repositories/order_repository.py`).
- Keep internal helpers private. Only export what consumers need.
- Place shared utilities in a clearly named `shared/` or `common/` directory. If a utility is only used by one module, keep it in that module.
- Index/barrel files should re-export public API only — no logic.

## Error Handling

- Handle errors at the appropriate level — do not catch and ignore.
- Use typed/specific errors, not generic strings or catch-all exceptions.
- Fail fast: validate inputs at function entry with guard clauses.
- Never swallow exceptions silently. At minimum, log and re-raise.
- Distinguish between recoverable errors (retry, fallback) and fatal errors (crash with context).

```
# BAD
try:
    result = api.call()
except:
    pass

# GOOD
try:
    result = api.call()
except ApiTimeoutError:
    logger.warning("API timeout, retrying", exc_info=True)
    result = api.call_with_backoff()
except ApiAuthError:
    raise  # caller must handle auth failures
```
