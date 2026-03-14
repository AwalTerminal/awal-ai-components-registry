# Shell/Bash Style Rules

## Safety
- Start every script with `set -euo pipefail` — fail on errors, unset variables, and pipe failures
- Always use `#!/usr/bin/env bash` shebang (or `#!/bin/sh` for POSIX scripts)
- Quote ALL variable expansions: `"$var"`, `"${array[@]}"`, `"$(command)"`
- Use `[[ ]]` for conditionals, not `[ ]` or `test` — avoids word splitting issues

## Formatting
- Use `shfmt` for consistent formatting (Google style: `shfmt -i 2 -ci`)
- 2-space indentation (Google Shell Style Guide convention)
- Keep lines under 80 characters — use `\` for continuation
- One blank line between function definitions
- Place `then`/`do` on the same line as `if`/`while`/`for`

## Naming
- Constants and environment variables: `UPPER_SNAKE_CASE` (`MAX_RETRIES`, `CONFIG_DIR`)
- Local variables and functions: `lower_snake_case` (`file_count`, `process_item`)
- Script names: `kebab-case` or `snake_case` (`deploy-app.sh`, `run_tests.sh`)
- Use meaningful names — avoid single-letter variables except loop counters

## Variables
- Declare local variables with `local` inside functions
- Use `readonly` for constants: `readonly CONFIG_DIR="/etc/myapp"`
- Use `declare -r` for readonly, `declare -i` for integers, `declare -a` for arrays
- Prefer `${var:-default}` for defaults, `${var:?error}` for required variables
- Use `"${var}"` brace form for clarity in complex expressions

## Functions
- Use `funcname() { }` syntax — omit `function` keyword
- Return exit codes, not strings — capture output with `$(funcname)`
- Use `local` for ALL function variables
- Keep functions under 50 lines — one task per function
- Add a usage/help function for scripts with arguments

## Input/Output
- Use `printf` over `echo` for portable, predictable output
- Redirect stderr for error and diagnostic messages: `echo "Error: ..." >&2`
- Use `mktemp` for temporary files — never hardcode temp paths
- Use `read -r` to prevent backslash interpretation
- Use heredocs for multi-line strings — single-quote the delimiter to prevent expansion

## Control Flow
- Prefer `case` over long `if/elif` chains
- Use `||` and `&&` for simple conditionals: `[[ -f "$f" ]] || die "Not found"`
- Avoid deeply nested conditionals — use guard clauses with early return/exit
- Use `while IFS= read -r line` for safe line-by-line processing

## Error Handling
- Use `trap cleanup EXIT` for guaranteed cleanup
- Provide meaningful error messages with context: `die "Cannot read $file: permission denied"`
- Check command existence with `command -v` before using optional tools
- Use `|| return 1` after critical commands inside functions

## Linting
- Run `shellcheck` on all scripts — fix all warnings before committing
- Use `shellcheck -x` to follow sourced files
- Enable `shellcheck` in your editor for real-time feedback
- Address SC-prefixed warnings by fixing the code, not disabling the check
