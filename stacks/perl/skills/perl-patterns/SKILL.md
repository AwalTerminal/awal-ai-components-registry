# Perl Patterns

## Modern Perl
- Use `use strict` and `use warnings` in every file — no exceptions
- Use `use v5.36` or later for modern features (signatures, `say`, `state`)
- Prefer `say` over `print` when a newline is needed
- Use subroutine signatures instead of manual `@_` unpacking
- Use `Scalar::Util`, `List::Util`, and `List::MoreUtils` for utility functions

## Error Handling
- Use `try/catch` from `Syntax::Keyword::Try` or `Feature::Compat::Try` for structured error handling
- Use `die` with an object or structured message, not bare strings
- Use `eval { }` with `$@` only when modern try/catch is unavailable
- Validate inputs at function boundaries — fail early with clear error messages

## Data Structures
- Use hash references for structured data: `{ name => "foo", count => 42 }`
- Use `Moo` or `Moose` for object-oriented code — avoid raw `bless`
- Use `Type::Tiny` for type constraints in `Moo`/`Moose` attributes
- Prefer array references over arrays for passing lists to functions
- Use `JSON::MaybeXS` for JSON serialization

## Project Structure
- Use `Dist::Zilla` or `Minilla` for distribution management
- Organize modules under `lib/` following the namespace hierarchy
- Place tests in `t/` — one `.t` file per module or feature
- Use `cpanfile` to declare dependencies

## Testing
- Use `Test2::V0` as the modern test framework
- Use `Test2::Mock` for mocking — avoid global monkey-patching
- Write tests for edge cases — Perl is permissive, so guard against unexpected input
- Use `prove -lr t/` to run all tests recursively
