# Perl Style Rules

## Pragmas
- Always include `use v5.36` (or latest stable) — enables `strict`, `warnings`, signatures, and `say`
- Use `use utf8` when source contains non-ASCII characters
- Add `use Feature::Compat::Try` for structured error handling

## Formatting
- Use `perltidy` with a `.perltidyrc` config — run before every commit
- 4-space indentation (Perl convention)
- Keep lines under 100 characters
- Opening brace on the same line: `sub foo ($arg) {`
- One blank line between subroutines

## Naming
- Subroutines and variables: `snake_case` (`process_order`, `$user_name`)
- Package/class names: `PascalCase` (`MyApp::UserService`)
- Constants: `UPPER_SNAKE_CASE` or use `use constant`
- Private methods: prefix with `_` (`sub _validate`)
- Avoid single-letter variable names except `$_`, `@_`, loop iterators

## Variables
- Use `my` for lexical scope — avoid global variables
- Prefer `//` (defined-or) over `||` for default values: `$x // "default"`
- Declare variables in the smallest possible scope
- Use `state` for persistent local variables (instead of closure-captured `my`)

## Subroutines
- Use subroutine signatures: `sub greet ($name, $greeting = "Hello")`
- Avoid manual `@_` unpacking in new code
- Return early for guard clauses rather than deep nesting
- Keep subroutines under 40 lines — extract helpers

## Regular Expressions
- Use the `/x` flag for complex regexes — add comments explaining each part
- Use named captures `(?<name>...)` over numbered `$1`, `$2`
- Avoid `$&`, `$``, `$'` — they impose a global performance penalty (pre-5.20)
- Prefer `qr//` for reusable compiled patterns

## Error Handling
- Use `try/catch` from `Feature::Compat::Try` — avoid bare `eval { }`
- Die with structured data (hashrefs or objects), not bare strings
- Validate inputs at subroutine boundaries with guard clauses

## OOP
- Use `Moo` for lightweight classes, `Moose` when full metaobject protocol is needed
- Use `Types::Standard` for attribute type constraints
- Use roles (`Moo::Role`) instead of multiple inheritance
- Never use raw `bless` in new code

## Documentation
- Write POD documentation for all public modules and subroutines
- Include `=head1 NAME`, `=head1 SYNOPSIS`, `=head1 DESCRIPTION` sections
- Add `=head2` for each public method

## Linting
- Run `perlcritic` at severity 4+ and address all violations
- Use `perlcritic --profile .perlcriticrc` for project-specific rules
- Run `perltidy --check` in CI to enforce formatting
