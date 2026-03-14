# Elixir Patterns

## OTP Patterns

### GenServer

```elixir
defmodule MyApp.Cache do
  use GenServer

  # Client API
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, %{}, name: name)
  end

  def get(server \\ __MODULE__, key) do
    GenServer.call(server, {:get, key})
  end

  def put(server \\ __MODULE__, key, value, ttl \\ :infinity) do
    GenServer.cast(server, {:put, key, value, ttl})
  end

  # Server callbacks
  @impl true
  def init(_opts) do
    schedule_cleanup()
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    case Map.get(state, key) do
      {value, expiry} when expiry > System.monotonic_time(:millisecond) ->
        {:reply, {:ok, value}, state}
      _ ->
        {:reply, :error, Map.delete(state, key)}
    end
  end

  @impl true
  def handle_cast({:put, key, value, ttl}, state) do
    expiry = if ttl == :infinity, do: :infinity, else: System.monotonic_time(:millisecond) + ttl
    {:noreply, Map.put(state, key, {value, expiry})}
  end
end
```

### Supervisor

```elixir
defmodule MyApp.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {MyApp.Cache, name: MyApp.Cache},
      {DynamicSupervisor, name: MyApp.WorkerSupervisor, strategy: :one_for_one},
      {Task.Supervisor, name: MyApp.TaskSupervisor},
    ]
    Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
  end
end

# Start workers dynamically
DynamicSupervisor.start_child(MyApp.WorkerSupervisor, {MyApp.Worker, job_id: 123})
```

## Pattern Matching

```elixir
# Function head matching — no if/else needed
def process(%{status: :active, role: :admin} = user) do
  grant_full_access(user)
end

def process(%{status: :active} = user) do
  grant_basic_access(user)
end

def process(%{status: :suspended} = user) do
  {:error, :account_suspended}
end

# Binary pattern matching for protocol parsing
def parse_header(<<
  version::8,
  type::8,
  length::16-big,
  payload::binary-size(length),
  rest::binary
>>) do
  {:ok, %{version: version, type: type, payload: payload}, rest}
end

# Pin operator — match against existing value
expected_id = 42
case fetch_record() do
  %{id: ^expected_id} -> :found
  %{id: other_id} -> {:wrong_id, other_id}
end
```

## Pipelines and With

```elixir
# Pipe operator for clear data transformation
def create_user(params) do
  params
  |> normalize_email()
  |> validate_params()
  |> hash_password()
  |> insert_user()
end

# `with` for multi-step operations that may fail
def checkout(user_id, cart_id) do
  with {:ok, user} <- Users.get(user_id),
       {:ok, cart} <- Carts.get(cart_id),
       {:ok, order} <- Orders.create(user, cart),
       {:ok, charge} <- Payments.charge(user, order.total) do
    {:ok, %{order: order, charge: charge}}
  end
end
```

## Protocols and Behaviours

```elixir
# Protocol — polymorphism for data types
defprotocol Renderable do
  def render(data)
end

defimpl Renderable, for: Map do
  def render(map), do: map |> Enum.map(fn {k, v} -> "<dt>#{k}</dt><dd>#{v}</dd>" end) |> Enum.join()
end

# Behaviour — contract for modules
defmodule MyApp.PaymentGateway do
  @callback charge(integer(), String.t()) :: {:ok, String.t()} | {:error, atom()}
  @callback refund(String.t()) :: {:ok, String.t()} | {:error, atom()}
end
```

## Concurrency

```elixir
# Task for async work with result
task = Task.async(fn -> expensive_computation() end)
result = Task.await(task, 5_000)  # 5 second timeout

# Parallel map with controlled concurrency
Task.async_stream(items, &process_item/1,
  max_concurrency: System.schedulers_online(),
  timeout: 30_000
)
|> Enum.to_list()

# Agent for simple state
{:ok, counter} = Agent.start_link(fn -> 0 end)
Agent.update(counter, &(&1 + 1))
Agent.get(counter, & &1)  # => 1
```

## Phoenix and Ecto Patterns

```elixir
defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :email, :string
    field :role, Ecto.Enum, values: [:user, :admin, :moderator]
    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :role])
    |> validate_required([:name, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
```

- Use contexts (bounded modules) to group related business logic
- Use `Ecto.Multi` for transactional multi-step operations
- Use changesets for all data validation and casting
- Use LiveView for interactive UIs with server-rendered state

## Performance

- **ETS**: use for fast in-memory key-value storage shared across processes
- **Binary handling**: use binary pattern matching for protocol parsing; avoid repeated concatenation
- **Process pools**: use `poolboy` or `NimblePool` for bounded worker pools
- **Stream**: use `Stream` for lazy evaluation of large datasets
- Profile with `:observer.start()`, `Benchee`, and `:recon`

```elixir
# ETS table for fast reads
:ets.new(:config_cache, [:set, :public, :named_table, read_concurrency: true])
:ets.insert(:config_cache, {"key", "value"})
[{"key", value}] = :ets.lookup(:config_cache, "key")

# Stream for lazy processing
File.stream!("large_file.csv")
|> Stream.map(&String.trim/1)
|> Stream.reject(&(&1 == ""))
|> Stream.chunk_every(1000)
|> Enum.each(&bulk_insert/1)
```

## Testing

```elixir
defmodule MyApp.AccountsTest do
  use MyApp.DataCase, async: true

  describe "create_user/1" do
    test "creates user with valid attrs" do
      assert {:ok, user} = Accounts.create_user(%{name: "Jane", email: "jane@example.com"})
      assert user.name == "Jane"
    end

    test "rejects invalid email" do
      assert {:error, changeset} = Accounts.create_user(%{name: "Jane", email: "bad"})
      assert "has invalid format" in errors_on(changeset).email
    end
  end
end
```

- Use `Mox` for mocking — define behaviours, mock in tests
- Use `async: true` for tests that do not share state
- Use `ExUnitProperties` for property-based testing
- Use `Ecto.Adapters.SQL.Sandbox` for concurrent database tests
