# Shell/Bash Patterns

## Script Safety

Every script starts with safety settings and structured entry point.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Constants
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

main() {
    parse_args "$@"
    validate_environment
    do_work
}

main "$@"
```

## Parameter Expansion

```bash
# Default values
name="${1:-world}"                    # default if unset or empty
db_url="${DATABASE_URL:?Must set DATABASE_URL}"  # error if unset

# String manipulation
filename="archive.tar.gz"
echo "${filename%.tar.gz}"            # "archive" — strip suffix
echo "${filename##*.}"                # "gz" — longest prefix removal
echo "${filename%%.*}"                # "archive" — longest suffix removal

# Substitution
path="/usr/local/bin/app"
echo "${path/local/share}"            # "/usr/share/bin/app" — replace first
echo "${path//\//_}"                  # "_usr_local_bin_app" — replace all

# Length and substrings
str="Hello, World!"
echo "${#str}"                        # 13 — length
echo "${str:7:5}"                     # "World" — substring

# Case conversion (Bash 4+)
echo "${str^^}"                       # "HELLO, WORLD!" — uppercase
echo "${str,,}"                       # "hello, world!" — lowercase
```

## Process Substitution

```bash
# Compare two command outputs
diff <(sort file1.txt) <(sort file2.txt)

# Feed command output as a file to a program
while IFS= read -r line; do
    process "$line"
done < <(grep -r "TODO" src/)

# Tee output to both file and next command
command | tee >(logger -t myapp) | grep "ERROR"
```

## Trap and Signal Handling

```bash
# Cleanup on exit, error, or signal
cleanup() {
    local exit_code=$?
    rm -f "$tmpfile"
    if [[ $exit_code -ne 0 ]]; then
        echo "ERROR: Script failed with exit code $exit_code" >&2
    fi
    exit "$exit_code"
}

tmpfile="$(mktemp)"
trap cleanup EXIT

# Trap specific signals
trap 'echo "Interrupted" >&2; exit 130' INT TERM

# Lock file pattern to prevent concurrent execution
lock_file="/var/run/${SCRIPT_NAME}.lock"
exec 200>"$lock_file"
flock -n 200 || { echo "Already running" >&2; exit 1; }
```

## Arrays

```bash
# Indexed arrays
files=("config.yaml" "data.json" "script.sh")
files+=("extra.txt")                   # append

echo "${files[0]}"                     # first element
echo "${files[@]}"                     # all elements (preserving quotes)
echo "${#files[@]}"                    # length

# Iterate safely (preserves spaces in elements)
for file in "${files[@]}"; do
    echo "Processing: $file"
done

# Associative arrays (Bash 4+)
declare -A config
config[host]="localhost"
config[port]="8080"
config[debug]="true"

for key in "${!config[@]}"; do
    echo "$key = ${config[$key]}"
done

# Array filtering
errors=()
for file in "${files[@]}"; do
    if ! validate "$file"; then
        errors+=("$file")
    fi
done
```

## Here Documents

```bash
# Heredoc — variable expansion
cat <<EOF
Hello, $USER
Today is $(date +%Y-%m-%d)
Working in $PWD
EOF

# Heredoc — no expansion (quoted delimiter)
cat <<'EOF'
This is literal: $USER $(date)
No expansion happens here
EOF

# Heredoc to a command
mysql -u root <<SQL
CREATE DATABASE IF NOT EXISTS myapp;
GRANT ALL ON myapp.* TO 'app'@'localhost';
SQL

# Indented heredoc (strip leading tabs)
if true; then
    cat <<-EOF
		This text can be indented with tabs
		Tabs are stripped from the output
	EOF
fi
```

## Quoting Rules

```bash
# ALWAYS quote variables — prevents word splitting and globbing
cp "$source" "$destination"

# Double quotes: expand variables and commands
echo "Hello, $USER at $(hostname)"

# Single quotes: everything is literal
echo 'No expansion: $USER $(date)'

# Quote arrays properly
args=("--flag" "value with spaces" "--other")
command "${args[@]}"

# Quote command substitution
result="$(some_command)"
if [[ -z "$result" ]]; then echo "Empty"; fi
```

## Portability: POSIX vs Bash

```bash
# POSIX-compatible (works in sh, dash, busybox)
if [ "$x" = "value" ]; then echo "match"; fi   # single bracket
command -v curl >/dev/null 2>&1                  # check command exists

# Bash-specific (requires #!/usr/bin/env bash)
if [[ "$x" == "value" ]]; then echo "match"; fi  # double bracket
[[ "$str" =~ ^[0-9]+$ ]]                          # regex matching
declare -A assoc_array                             # associative arrays
```

## Logging and Error Functions

```bash
log_info()  { printf '[INFO]  %s\n' "$*"; }
log_warn()  { printf '[WARN]  %s\n' "$*" >&2; }
log_error() { printf '[ERROR] %s\n' "$*" >&2; }

die() {
    log_error "$@"
    exit 1
}

# Usage
[[ -f "$config_file" ]] || die "Config not found: $config_file"
```

## Argument Parsing

```bash
usage() {
    cat >&2 <<EOF
Usage: $SCRIPT_NAME [OPTIONS] <input-file>

Options:
    -o, --output FILE    Output file (default: stdout)
    -v, --verbose        Enable verbose output
    -h, --help           Show this help message
EOF
    exit 1
}

parse_args() {
    local output="" verbose=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)  output="$2"; shift 2 ;;
            -v|--verbose) verbose=true; shift ;;
            -h|--help)    usage ;;
            --)           shift; break ;;
            -*)           die "Unknown option: $1" ;;
            *)            break ;;
        esac
    done
    [[ $# -ge 1 ]] || usage
    INPUT_FILE="$1"
}
```

## Testing with bats-core

```bash
# test/example.bats
@test "script exits 0 with valid input" {
    run ./myscript.sh test/fixtures/valid.txt
    [ "$status" -eq 0 ]
}

@test "script fails on missing file" {
    run ./myscript.sh nonexistent.txt
    [ "$status" -ne 0 ]
    [[ "$output" =~ "not found" ]]
}

@test "output contains expected header" {
    run ./myscript.sh test/fixtures/data.csv
    [ "${lines[0]}" = "name,count" ]
}
```
