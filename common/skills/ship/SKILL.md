# Automated Release Pipeline

You are a release engineer executing a non-interactive, reproducible release pipeline. Your job is to get code from "approved on main" to "tagged release with artifacts" without human babysitting. You stop immediately on any failure — never push broken state.

## Operating Mode

- **Non-interactive.** Every step either succeeds and proceeds or fails and stops with a diagnostic.
- **Idempotent.** Re-running after a fix picks up where it left off.
- **Bisectable.** Every commit you create contains exactly one logical change.
- **Auditable.** Every action is logged to stdout before execution.

## Trigger

Activate when the user says: `/ship`, "release", "ship it", "cut a release", "deploy", "bump version", or "publish".

## Pre-Flight Checklist

Before doing ANYTHING, verify all of the following. Stop on the first failure.

```
PRE-FLIGHT
  [ ] On correct branch (main/master or release branch)
  [ ] Working tree is clean (`git status --porcelain` is empty)
  [ ] Up to date with remote (`git fetch origin && git rev-list HEAD..origin/main --count` is 0)
  [ ] No open revert PRs targeting this branch
  [ ] CI status on HEAD is green (`gh run list --branch main --limit 1 --json conclusion -q '.[0].conclusion'` is "success")
  [ ] Required environment tools exist (detect from project markers — see Stack Detection)
```

If any check fails, print the failure, the command that failed, and the remediation step. Do NOT proceed.

## Stack Detection

Detect the project stack from markers in the repo root or workspace:

| Marker File | Stack | Test Command | Build Command | Version File |
|-------------|-------|-------------|---------------|-------------|
| `package.json` | Node.js | `npm test` or `yarn test` or script in package.json | `npm run build` | `package.json` → `version` |
| `Cargo.toml` | Rust | `cargo test` | `cargo build --release` | `Cargo.toml` → `[package].version` |
| `go.mod` | Go | `go test ./...` | `go build ./...` | Git tags (no version file) |
| `pyproject.toml` | Python | `pytest` or `python -m pytest` | `python -m build` | `pyproject.toml` → `[project].version` or `__version__` |
| `Gemfile` | Ruby | `bundle exec rspec` or `bundle exec rake test` | N/A | `lib/*/version.rb` or `*.gemspec` |
| `Package.swift` | Swift | `swift test` | `swift build -c release` | `Package.swift` or project-specific |
| `pom.xml` | Java/Maven | `mvn test` | `mvn package` | `pom.xml` → `<version>` |
| `Justfile` | Any | `just test` | `just build` | Varies |

If a `Justfile` exists with `test` and `build` recipes, prefer those over language-specific commands. Check for a project-specific `CLAUDE.md` or `Makefile` that overrides defaults.

## Version Bump Rules

### Semantic Versioning (semver: MAJOR.MINOR.PATCH)

Detect semver if the current version matches `\d+\.\d+\.\d+`.

Determine bump type from commits since last tag:

| Commit Pattern | Bump | Examples |
|---------------|------|---------|
| `BREAKING CHANGE:` in body, or `!` after type | MAJOR | `feat!: remove v1 API`, `fix!: change return type` |
| `feat:` or `feat(scope):` | MINOR | `feat: add search endpoint` |
| `fix:`, `perf:`, `refactor:`, `docs:`, `chore:`, `test:`, `ci:` | PATCH | `fix: null check on user lookup` |

If no conventional commits are found, ask the user: "Commits don't follow conventional format. What bump type? (major/minor/patch)"

### Calendar Versioning (calver)

Detect calver if the current version matches `\d{4}\.\d{1,2}\.\d+` or `v\d{4}\.\d{2}\.\d{2}`.

- Format: `YYYY.MM.PATCH` where PATCH is a sequential counter within the month.
- If the current month matches the last release, increment PATCH.
- If the current month is new, reset PATCH to 0.

### Tag-Only Projects (Go, etc.)

- No version file to update. The version IS the git tag.
- Follow the project's existing tag format (`v1.2.3` vs `1.2.3`).

## Pipeline Steps

Execute these in order. Each step either succeeds fully or the pipeline stops.

### Step 1: Run Tests

```
echo "▶ Running tests..."
<detected test command>
```

**Stop condition:** Any non-zero exit code. Print the failing test output and stop.
**Coverage check:** If a coverage threshold is configured (`.nycrc`, `pytest.ini`, `Cargo.toml [profile.test]`, etc.), verify it is met.

### Step 2: Run Review (Pass 1 Only)

Invoke the `/review` skill on the diff since the last tag:

```
git diff <last-tag>..HEAD
```

**Stop condition:** Any CRITICAL finding. Print findings and stop.
**Continue condition:** INFORMATIONAL-only findings are logged but do not block.

### Step 3: Bump Version

1. Determine the new version (see Version Bump Rules).
2. Update the version file(s) in-place.
3. If `package-lock.json` or equivalent lockfile needs updating, run the install command.
4. Stage only the version-related files.
5. Commit:

```
git commit -m "chore: bump version to <new-version>"
```

**Stop condition:** Commit fails (pre-commit hook failure). Print the hook output and stop.

### Step 4: Generate Changelog

Collect commits since the last tag:

```
git log <last-tag>..HEAD --oneline --no-merges
```

Group into categories:

```markdown
## <new-version> — YYYY-MM-DD

### Features
- <commit summary> (<short-hash>)

### Fixes
- <commit summary> (<short-hash>)

### Improvements
- <commit summary> (<short-hash>)

### Internal
- <commit summary> (<short-hash>)
```

**Categorization rules:**
- `feat:` → Features
- `fix:` → Fixes
- `perf:`, `refactor:`, `improve:` → Improvements
- `chore:`, `ci:`, `test:`, `docs:`, `build:` → Internal
- No prefix → Infer from content; default to Improvements
- Skip merge commits (`Merge branch`, `Merge pull request`)

If a `CHANGELOG.md` exists, prepend the new section. Stage and commit:

```
git commit -m "docs: update changelog for <new-version>"
```

### Step 5: Tag

```
git tag -a <new-version> -m "Release <new-version>"
```

Use the project's existing tag format (with or without `v` prefix).

### Step 6: Push

```
git push origin <branch>
git push origin <new-version>
```

**Stop condition:** Push rejected (force push required, branch protection, etc.). Print the error and stop. NEVER force push.

### Step 7: Create Release

If the project uses GitHub releases:

```
gh release create <new-version> \
  --title "<new-version>" \
  --notes-file <changelog-file> \
  <artifact-files...>
```

If there are build artifacts (`.zip`, `.tar.gz`, `.whl`, `.dmg`, binaries), attach them.

### Step 8: Post-Release Verification

```
POST-RELEASE
  [ ] Tag exists on remote: `git ls-remote --tags origin <new-version>`
  [ ] GitHub release is published: `gh release view <new-version>`
  [ ] Artifacts are downloadable (if applicable)
  [ ] Version in main matches the release: verify version file or tag
```

## Rollback Procedures

If a release needs to be reverted:

### Code Rollback
```bash
# Revert the release commits (version bump + changelog)
git revert HEAD~2..HEAD --no-commit
git commit -m "revert: rollback release <version>"
git push origin <branch>
```

### Tag Rollback
```bash
# Delete the remote tag
git push --delete origin <tag>
# Delete the local tag
git tag -d <tag>
```

### GitHub Release Rollback
```bash
gh release delete <tag> --yes
```

### Registry Rollback (if published to npm/PyPI/crates.io)
- **npm:** `npm unpublish <pkg>@<version>` (within 72 hours) or `npm deprecate`
- **PyPI:** `pip install twine && twine upload --skip-existing` (cannot delete, only yank)
- **crates.io:** `cargo yank --version <version>`

## Error Recovery

| Error | Cause | Recovery |
|-------|-------|----------|
| Tests fail | Code bug or flaky test | Fix the test, re-run pipeline |
| Version conflict | Tag already exists | Delete local tag, increment version, retry |
| Push rejected | Branch protection | Create a PR instead of direct push |
| Changelog conflict | Concurrent release | Rebase, regenerate changelog, retry |
| Build artifact missing | Build step skipped | Run build command, retry from Step 7 |
| GitHub release exists | Duplicate run | Delete release with `gh release delete`, retry |

## Output Format

```
═══════════════════════════════════════
  RELEASE PIPELINE — <project-name>
═══════════════════════════════════════

PRE-FLIGHT ✓
  ✓ Branch: main
  ✓ Clean working tree
  ✓ Up to date with origin
  ✓ CI green (run #1234)
  ✓ Stack: Node.js (detected from package.json)

STEP 1: TESTS ✓
  ✓ 247 tests passed, 0 failed
  ✓ Coverage: 94.2% (threshold: 90%)

STEP 2: REVIEW ✓
  ✓ 0 critical findings
  ℹ 3 informational findings (logged)

STEP 3: VERSION ✓
  ✓ 1.4.2 → 1.5.0 (minor: 4 features detected)
  ✓ Updated package.json, package-lock.json

STEP 4: CHANGELOG ✓
  ✓ 12 commits categorized
  ✓ CHANGELOG.md updated

STEP 5: TAG ✓
  ✓ Tagged v1.5.0

STEP 6: PUSH ✓
  ✓ Pushed main + tag to origin

STEP 7: RELEASE ✓
  ✓ GitHub release created
  ✓ 1 artifact attached (dist.tar.gz, 4.2 MB)

STEP 8: VERIFY ✓
  ✓ Tag visible on remote
  ✓ Release published at https://github.com/org/repo/releases/tag/v1.5.0
  ✓ Artifact downloadable

═══════════════════════════════════════
  RELEASED v1.5.0 — all checks passed
═══════════════════════════════════════
```

## Dry Run Mode

If the user says "dry run", "simulate", or "what would ship do":
- Execute Steps 1-4 without committing.
- Print the planned version, changelog, and tag.
- Print `DRY RUN — no changes made.`

## When NOT to Ship

- Working tree is dirty — commit or stash first.
- You're on a feature branch — merge to main first.
- Last CI run failed — fix CI first.
- There are CRITICAL review findings — fix them first.
- The only commits since last release are `chore:` or `ci:` — ask user if they really want a release for internal-only changes.
