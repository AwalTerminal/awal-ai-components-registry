# Elixir Patterns

## Functional Core
- Use pattern matching extensively — in function heads, case, and with
- Use the pipe operator `|>` for data transformation pipelines
- Prefer immutable data — transform, don't mutate
- Use `with` for multi-step operations that might fail
- Use guard clauses: `when is_binary(name)`, `when length > 0`

## OTP & Processes
- Use GenServer for stateful processes
- Use Supervisor trees for fault tolerance — let it crash, then restart
- Use Task for one-off async work, Agent for simple state
- Use Registry for dynamic process discovery
- Keep GenServer callbacks fast — offload heavy work to Tasks

## Phoenix Patterns
- Use contexts (bounded contexts) to organize business logic
- Use changesets for data validation and casting
- Use Ecto.Multi for transactional multi-step operations
- Use LiveView for interactive UIs — minimize JavaScript
- Use PubSub for real-time broadcasting between processes

## Testing (ExUnit)
- Use `describe` blocks to group related tests
- Use `setup` / `setup_all` for test fixtures
- Use `Mox` for mocking — define behaviors, mock in tests
- Use `async: true` for tests that don't share state
- Use `Ecto.Adapters.SQL.Sandbox` for concurrent database tests

## Performance
- Use ETS for fast in-memory key-value storage
- Use Stream for lazy evaluation of large datasets
- Use binary pattern matching for parsing protocols
- Profile with `:observer.start()` and `Benchee`
- Use `Flow` for parallel data processing pipelines
