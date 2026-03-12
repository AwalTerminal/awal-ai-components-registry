# Shell/Bash Style Rules

- Run `shellcheck` on all scripts — fix all warnings before committing
- Use `shfmt` for consistent formatting (Google style: 2-space indent, `shfmt -i 2`)
- Always set `set -euo pipefail` at the top of every script
- Quote all variable expansions — `"$var"`, `"${array[@]}"`, `"$(command)"`
- Use `UPPER_SNAKE_CASE` for constants and environment variables, `lower_snake_case` for locals
- Use `[[ ]]` for tests, not `[ ]` or `test` — avoids word splitting issues
- Keep lines under 80 characters — use `\` for continuation
- Add a usage/help function that prints to stderr when the script is called with wrong arguments
