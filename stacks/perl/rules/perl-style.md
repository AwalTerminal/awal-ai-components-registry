# Perl Style Rules

- Use `perltidy` with a `.perltidyrc` config — run before committing
- Always include `use strict` and `use warnings` at the top of every file
- Use `perlcritic` at severity 4+ and address all violations
- Use `snake_case` for subroutine and variable names, `PascalCase` for package names
- Use `my` for lexical scope — avoid global variables
- Prefer `//` (defined-or) over `||` for default values
- Write POD documentation for all public subroutines and modules
- Avoid complex regular expressions — use `/x` flag and named captures for readability
