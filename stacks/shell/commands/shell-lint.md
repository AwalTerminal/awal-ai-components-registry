# Shell Lint & Run Commands

## Running Scripts

- `bash script.sh` — run a script with bash
- `bash -x script.sh` — run with debug tracing (prints each command)
- `bash -n script.sh` — syntax-check without executing
- `chmod +x script.sh && ./script.sh` — make executable and run
- `env VAR=value ./script.sh` — run with environment variable

## Linting (ShellCheck)

- `shellcheck script.sh` — lint a single script
- `shellcheck -x scripts/*.sh` — lint all scripts, following sourced files
- `shellcheck --severity=warning scripts/*.sh` — only show warnings and errors
- `shellcheck --format=diff script.sh` — show fixes as a diff
- `shellcheck --shell=bash script.sh` — explicitly specify shell dialect
- `shellcheck --exclude=SC2086 script.sh` — exclude specific rules

## Formatting (shfmt)

- `shfmt -d .` — show formatting diff (dry run)
- `shfmt -w .` — format all shell files in-place
- `shfmt -i 2 -ci -w script.sh` — format with 2-space indent, indent switch cases
- `shfmt -l .` — list files that need formatting

## Testing (bats-core)

- `bats test/` — run all test files in directory
- `bats test/specific.bats` — run a specific test file
- `bats --tap test/` — output in TAP format
- `bats --filter "pattern" test/` — run tests matching pattern
- `bats --jobs 4 test/` — run tests in parallel

## Testing (shunit2)

- `bash test/test_script.sh` — run shunit2 test file directly

## Debugging

- `bash -x script.sh` — trace execution (print every command)
- `bash -v script.sh` — verbose mode (print lines as read)
- `PS4='+ ${BASH_SOURCE}:${LINENO}: ' bash -x script.sh` — trace with file and line numbers
- `set -x` / `set +x` — enable/disable tracing within a script

## Portability Checking

- `checkbashisms script.sh` — check for non-POSIX bashisms
- `shellcheck --shell=sh script.sh` — lint as POSIX shell
- `dash script.sh` — test with a strict POSIX shell

## Dependency Checking

- `command -v curl >/dev/null 2>&1` — check if a command exists
- `type -P program` — print path if program exists (bash-specific)
- `which program 2>/dev/null` — locate program (less portable)
