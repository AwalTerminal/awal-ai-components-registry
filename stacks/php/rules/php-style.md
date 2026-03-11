# PHP Style Rules

- Follow PSR-12 coding standard
- Use strict types: `declare(strict_types=1);` at the top of every file
- Use typed properties, parameters, and return types
- Use readonly properties for immutable value objects (PHP 8.1+)
- Use enums instead of class constants for fixed sets (PHP 8.1+)
- Use `match` over `switch` for value mapping
- Never use `@` error suppression operator
- Use `final` on classes by default — open only when inheritance is designed for
