# PHP Patterns

## Modern PHP (8.x)
- Use typed properties, union types, and return types everywhere
- Use `match` expression over `switch` for value mapping
- Use named arguments for readability: `route(path: '/users', method: 'GET')`
- Use enums (PHP 8.1+) instead of class constants for fixed sets
- Use readonly properties and classes for immutable value objects
- Use fiber-based async where supported

## Error Handling
- Use exceptions for exceptional cases, return types for expected failures
- Create specific exception classes per domain
- Never catch `\Exception` or `\Throwable` broadly — be specific
- Use `set_error_handler` to convert legacy errors to exceptions

## Laravel Patterns
- Use Eloquent scopes for reusable query logic
- Use Form Requests for validation — keep controllers thin
- Use Events and Listeners for decoupled side effects
- Use Jobs for background processing with proper retry/failure handling
- Use `DB::transaction()` for multi-step database operations

## Security
- Use prepared statements (Eloquent/PDO) — never concatenate SQL
- Escape output with `htmlspecialchars()` or Blade's `{{ }}` syntax
- Validate and sanitize all user input
- Use `password_hash()` / `password_verify()` — never MD5/SHA1 for passwords
- Set secure cookie flags: HttpOnly, Secure, SameSite

## Composer & Project Structure
- Follow PSR-4 autoloading and PSR-12 coding style
- Use `composer.lock` in version control for applications
- Use interfaces for service contracts
- Keep controllers thin — delegate to service classes
