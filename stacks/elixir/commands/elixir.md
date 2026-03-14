# Elixir Commands

## Mix
- `mix new project_name` — create a new project
- `mix new project_name --sup` — create with supervision tree
- `mix deps.get` — fetch dependencies
- `mix deps.update --all` — update all dependencies
- `mix compile` — compile the project
- `mix run` — compile and run
- `mix run --no-halt` — run without halting (for long-running apps)
- `iex -S mix` — start interactive shell with project loaded

## Testing
- `mix test` — run all tests
- `mix test test/accounts_test.exs` — run a specific file
- `mix test test/accounts_test.exs:42` — run a specific line
- `mix test --only tag:value` — run tests with a specific tag
- `mix test --stale` — run only tests affected by recent changes
- `mix test --cover` — run with coverage report
- `mix test --trace` — verbose output with test names

## Code Quality
- `mix format` — format all files
- `mix format --check-formatted` — check formatting (CI)
- `mix credo` — run Credo static analysis
- `mix credo --strict` — strict mode
- `mix dialyzer` — run Dialyzer type analysis (requires dialyxir dep)
- `mix dialyzer --plt` — build PLT cache (first run)

## Phoenix
- `mix phx.new app_name` — create a new Phoenix project
- `mix phx.server` — start the development server
- `iex -S mix phx.server` — start server with interactive shell
- `mix phx.routes` — list all routes
- `mix phx.gen.context Accounts User users name:string email:string` — generate context
- `mix phx.gen.live Accounts User users name:string email:string` — generate LiveView CRUD
- `mix phx.gen.auth Accounts User users` — generate authentication

## Ecto (Database)
- `mix ecto.create` — create the database
- `mix ecto.migrate` — run pending migrations
- `mix ecto.rollback` — rollback last migration
- `mix ecto.reset` — drop, create, migrate
- `mix ecto.gen.migration add_users` — generate a migration

## Release (Production)
- `MIX_ENV=prod mix release` — build a release
- `MIX_ENV=prod mix assets.deploy` — compile and digest static assets
- `_build/prod/rel/app_name/bin/app_name start` — start the release
- `_build/prod/rel/app_name/bin/app_name remote` — connect to running release
