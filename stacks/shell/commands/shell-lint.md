# Shell Lint & Run

Run with shellcheck and shfmt:
- `shellcheck script.sh` — lint a single script
- `shellcheck -x scripts/*.sh` — lint all scripts, following sourced files
- `shfmt -d .` — show formatting diff
- `shfmt -w .` — format all shell files in-place
- `bash -n script.sh` — syntax-check without executing
- `bats test/` — run tests (Bats test framework)
- `chmod +x script.sh && ./script.sh` — make executable and run
