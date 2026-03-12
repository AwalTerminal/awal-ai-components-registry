# Shell/Bash Patterns

## Safety
- Start every script with `set -euo pipefail` — fail on errors, unset variables, and pipe failures
- Quote all variable expansions: `"$var"` not `$var` — prevents word splitting and globbing
- Use `[[ ]]` for conditionals instead of `[ ]` — safer and more featureful
- Use `"${var:-default}"` for default values, `"${var:?error}"` for required variables
- Trap signals for cleanup: `trap 'rm -f "$tmpfile"' EXIT`

## Variables and Data
- Use `local` for variables inside functions to avoid polluting global scope
- Use `readonly` for constants: `readonly CONFIG_DIR="/etc/myapp"`
- Use arrays for lists: `files=("a.txt" "b.txt")` — iterate with `"${files[@]}"`
- Use `declare -A` for associative arrays (Bash 4+)
- Prefer `$()` over backticks for command substitution — nests cleanly

## Functions
- Define functions with `funcname() { }` syntax — no `function` keyword needed
- Return exit codes, not strings — use `echo`/`printf` for output
- Use `local` for all function variables
- Keep functions focused — one task per function
- Use `|| return 1` after critical commands inside functions

## Input/Output
- Use `printf` over `echo` for portable, predictable output
- Redirect stderr for error messages: `echo "Error: ..." >&2`
- Use `mktemp` for temporary files — never hardcode temp paths
- Use `read -r` to prevent backslash interpretation
- Use heredocs (`<<'EOF'`) for multi-line strings — single-quote the delimiter to prevent expansion

## Project Structure
- Place shared functions in a `lib/` directory — source them with `. lib/utils.sh`
- Add a `#!/usr/bin/env bash` shebang to every script
- Use `main() { }` pattern — call `main "$@"` at the end of the script
- Keep scripts under 200 lines — break larger tools into sourced modules
