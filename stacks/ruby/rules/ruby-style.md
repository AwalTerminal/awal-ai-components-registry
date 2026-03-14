# Ruby Style Rules

## Naming
- Classes and modules: `PascalCase`
- Methods and variables: `snake_case`
- Constants: `SCREAMING_SNAKE_CASE`
- Predicate methods: suffix with `?` (`empty?`, `valid?`, `admin?`)
- Dangerous/mutating methods: suffix with `!` (`save!`, `sort!`, `delete!`)
- Private methods: no underscore prefix — use `private` keyword section

## Formatting
- 2 spaces for indentation, no tabs
- Use `frozen_string_literal: true` magic comment at the top of every file
- No semicolons to separate statements
- No `for` loops — use `each`, `map`, `select`, and other iterators
- Parentheses optional for zero-arg methods; use them for methods with arguments
- Single-line blocks: `{ |x| x + 1 }` — multi-line blocks: `do...end`

## Idioms
- Prefer `&&`/`||` over `and`/`or` (different precedence causes subtle bugs)
- Use `&:method_name` shorthand for simple block operations
- Use guard clauses (`return if`, `return unless`) to reduce nesting
- Use `freeze` on string constants and default values
- Use `%w[]` for word arrays, `%i[]` for symbol arrays
- Prefer string interpolation `"Hello #{name}"` over concatenation

## Class Design
- Keep classes under 100 lines; extract collaborators when growing
- Prefer composition over inheritance
- Use modules for shared behavior (mixins), not deep class hierarchies
- Always implement `respond_to_missing?` alongside `method_missing`
- Use `Struct` or `Data` (Ruby 3.2+) for simple value objects

## Rails Conventions
- Follow "skinny controllers, fat models" — or better, use service objects
- Use `ActiveRecord` callbacks sparingly — prefer explicit service calls
- Use `scope` for reusable query conditions
- Use `strong_parameters` — never trust mass assignment
- Keep migrations reversible; avoid data manipulation in migrations

## Error Handling
- Rescue specific exceptions; never bare `rescue` (catches `StandardError`)
- Custom exceptions should inherit from `StandardError`, not `Exception`
- Use `ensure` for cleanup
- Use `retry` with a counter to prevent infinite loops
