# Ruby Patterns

## Idiomatic Ruby
- Use `snake_case` for methods and variables, `CamelCase` for classes
- Use `?` suffix for predicate methods: `empty?`, `valid?`
- Use `!` suffix for dangerous/mutating methods: `save!`, `sort!`
- Prefer blocks and iterators over manual loops: `map`, `select`, `reduce`
- Use `freeze` on string constants to prevent mutation

## Rails Patterns
- Follow "skinny controllers, fat models" — or better, use service objects
- Use `ActiveRecord` callbacks sparingly — prefer explicit service calls
- Use `scope` for reusable query conditions
- Use `strong_parameters` — never trust mass assignment
- Use background jobs (Sidekiq/GoodJob) for slow operations
- Use `ActiveRecord::Base.transaction` for multi-step writes

## Error Handling
- Rescue specific exceptions, never bare `rescue`
- Use custom exception classes inheriting from `StandardError`
- Use `ensure` for cleanup (like `finally`)
- Use `retry` judiciously with a counter to prevent infinite loops

## Testing (RSpec)
- Use `describe` for the subject, `context` for scenarios, `it` for behaviors
- Use `let` for lazy setup, `let!` for eager setup
- Use factories (FactoryBot) over fixtures
- Use `shared_examples` for common behavior across specs
- Mock external services, not internal collaborators

## Performance
- Use `includes` / `preload` to avoid N+1 queries
- Use `find_each` for batch processing large datasets
- Use caching (fragment, Russian doll) for expensive views
- Use `pluck` when you only need specific columns
