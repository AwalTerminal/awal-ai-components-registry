# PHP Style Rules

## File Structure
- Start every file with `declare(strict_types=1);`
- One class/interface/enum per file
- Use PSR-4 autoloading — namespace matches directory structure
- Order: `declare`, `namespace`, `use` statements (grouped: PHP classes, vendor, project), class body

## Naming
- Classes, interfaces, enums, traits: `PascalCase`
- Methods, functions, variables: `camelCase`
- Constants and enum cases: `UPPER_SNAKE_CASE` (constants) or `PascalCase` (enum cases)
- Boolean methods: prefix with `is`, `has`, `can`, `should`
- Interfaces: suffix with `Interface` (e.g., `UserRepositoryInterface`)

## Coding Standard (PSR-12)
- 4 spaces for indentation, no tabs
- Opening brace on same line for control structures, next line for classes/methods
- One blank line before `return` statements (when preceded by other code)
- No trailing whitespace, single blank line at end of file
- Use `match` over `switch` for value mapping
- Never use `@` error suppression operator

## Type System
- Use typed properties, parameters, and return types on every declaration
- Use `readonly` properties for immutable value objects (PHP 8.1+)
- Use enums instead of class constants for fixed sets (PHP 8.1+)
- Use union types (`string|int`) only when truly needed — prefer specific types
- Use intersection types (`Countable&Iterator`) for combined contracts
- Use `null` return types explicitly (`?string`) rather than implicit null

## Class Design
- Mark classes `final` by default — open only when inheritance is explicitly designed
- Prefer composition over inheritance
- Use constructor promotion for simple value objects
- Keep constructors free of logic — use static factory methods for complex creation
- Limit class dependencies to 4-5 constructor parameters; extract collaborators if more

## Error Handling
- Throw specific exception subclasses, not generic `\Exception`
- Never catch `\Exception` or `\Throwable` broadly
- Use return types (Result objects) for expected failure paths
- Reserve exceptions for truly exceptional conditions
