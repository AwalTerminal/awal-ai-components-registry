# Quality Assurance Testing

Systematically test an application, component, or page. Produce a structured health report with scored categories, evidenced findings, severity levels, and actionable remediation steps. Every finding requires proof -- a code reference, log excerpt, or screenshot.

## Invocation

```
/qa [mode] [scope]
```

| Argument | Default  | Options                                       |
|----------|----------|-----------------------------------------------|
| `mode`   | `full`   | `full`, `quick`, `regression`                 |
| `scope`  | project  | Path, URL, component name, or "project"       |

### Mode Definitions

| Mode         | Purpose                          | Duration Target | Categories Tested |
|--------------|----------------------------------|-----------------|-------------------|
| `full`       | Comprehensive quality audit      | Thorough        | All 8             |
| `quick`      | Smoke test for deploy readiness  | < 5 min         | 1, 2, 4, 8       |
| `regression` | Diff against known baseline      | Targeted        | Changed areas     |

---

## Workflow

### Phase 1: Scope Discovery

1. Identify the technology stack (framework, language, runtime).
2. Locate configuration files (`package.json`, `Cargo.toml`, `Makefile`, etc.).
3. Identify the test runner and existing test suites.
4. For `regression` mode: determine changed files via `git diff --name-only HEAD~1` (or specified baseline).

**Stop condition:** If the scope cannot be resolved to testable artifacts, ask the user to clarify. Do not guess.

### Phase 2: Test Execution

Run tests in category order. For each category, record pass/fail/skip and collect evidence.

#### Category 1: Console Errors (Weight: 15%)

- [ ] Build the project. Capture all warnings and errors from build output.
- [ ] Run the application. Monitor stdout/stderr for runtime errors.
- [ ] Check for unhandled exceptions, panics, or crash logs.
- [ ] Verify no deprecation warnings from core dependencies.

**Evidence required:** Exact error message with file and line number.

#### Category 2: Broken Links & References (Weight: 10%)

- [ ] Scan imports/includes for missing modules.
- [ ] Check configuration file references (paths, URLs, env vars).
- [ ] For web projects: validate internal links, image sources, stylesheet references.
- [ ] Verify all external API endpoints referenced in code are reachable.

**Evidence required:** The broken reference and its location.

#### Category 3: Visual Regression (Weight: 10%)

- [ ] Compare current UI rendering against baseline (if available).
- [ ] Check for layout overflow, truncation, or misalignment.
- [ ] Verify responsive breakpoints if applicable.
- [ ] Confirm dark/light mode consistency.

**Evidence required:** Description of visual defect with component path. Screenshot if tools support it.

#### Category 4: Functional Correctness (Weight: 20%)

- [ ] Run existing test suite. Record pass/fail counts.
- [ ] Verify core user flows work end-to-end.
- [ ] Test boundary conditions: empty input, max-length input, special characters.
- [ ] Confirm error states display appropriate messages.
- [ ] Test state transitions and data persistence.

**Evidence required:** Test output, or step-by-step reproduction for manual findings.

#### Category 5: UX Flows (Weight: 10%)

- [ ] Verify primary user journey completes without dead ends.
- [ ] Check loading states and feedback for async operations.
- [ ] Confirm navigation structure is consistent.
- [ ] Validate form validation messages are helpful and timely.

**Evidence required:** Flow description with the specific step that fails.

#### Category 6: Performance (Weight: 10%)

- [ ] Measure build time. Flag if > 2x typical for project size.
- [ ] Check for O(n^2) or worse patterns in hot paths.
- [ ] Identify unnecessary re-renders or recomputations.
- [ ] Flag unbounded data structures (lists without pagination, caches without eviction).
- [ ] Check bundle/binary size if applicable.

**Evidence required:** Code reference with complexity analysis or timing measurement.

#### Category 7: Content Accuracy (Weight: 10%)

- [ ] Verify user-facing strings match intended copy.
- [ ] Check date/number formatting for locale correctness.
- [ ] Confirm placeholder/sample data is not in production code.
- [ ] Validate documentation matches current behavior.

**Evidence required:** The inaccurate content and its location.

#### Category 8: Accessibility (Weight: 15%)

- [ ] Verify semantic structure (headings, landmarks, labels).
- [ ] Check color contrast ratios (minimum 4.5:1 for normal text).
- [ ] Confirm keyboard navigability for all interactive elements.
- [ ] Verify screen reader compatibility (alt text, ARIA attributes).
- [ ] Check focus management and tab order.

**Evidence required:** The element and the specific a11y violation.

---

### Phase 3: Health Score Computation

Score each category 0-10 using this rubric:

| Score | Meaning                                         |
|-------|--------------------------------------------------|
| 10    | No issues found                                  |
| 8-9   | Minor issues only (cosmetic, non-blocking)       |
| 6-7   | Moderate issues (degraded experience, workaround exists) |
| 4-5   | Significant issues (broken features, poor UX)    |
| 2-3   | Critical issues (data loss risk, security holes) |
| 0-1   | Category completely failing                      |

**Weighted health score** = Sum of (category_score * weight) across all tested categories.

| Overall Score | Rating       | Deploy Recommendation         |
|---------------|--------------|-------------------------------|
| 90-100        | Excellent    | Ship it                       |
| 75-89         | Good         | Ship with known issues logged |
| 60-74         | Acceptable   | Fix critical items first      |
| 40-59         | Poor         | Do not deploy                 |
| 0-39          | Critical     | Stop. Triage immediately      |

### Phase 4: Issue Reports

Every finding must follow this structure:

```markdown
### [SEVERITY] Short description

**Category:** Category N - Name
**Severity:** critical | major | minor | cosmetic
**Location:** file/path:line or component name

**Description:**
What is wrong and why it matters.

**Evidence:**
[exact error, code snippet, or screenshot]

**Reproduction:**
1. Step one
2. Step two
3. Observe: [what happens]
4. Expected: [what should happen]

**Suggested Fix:**
[concrete remediation with code reference]
```

#### Severity Definitions

| Severity | Criteria                                              | SLA        |
|----------|-------------------------------------------------------|------------|
| critical | Data loss, security vulnerability, complete breakage  | Fix before deploy |
| major    | Feature broken, significant UX degradation            | Fix within sprint |
| minor    | Cosmetic issue, edge case, degraded but functional    | Backlog    |
| cosmetic | Nitpick, style inconsistency, non-functional          | Optional   |

### Phase 5: Output

```markdown
# QA Report: [scope]

**Mode:** full | quick | regression
**Date:** YYYY-MM-DD
**Health Score:** XX/100 (Rating)
**Deploy Recommendation:** [recommendation]

## Score Breakdown

| Category              | Weight | Score | Weighted |
|-----------------------|--------|-------|----------|
| Console Errors        | 15%    | X/10  | X.X      |
| Broken Links          | 10%    | X/10  | X.X      |
| Visual Regression     | 10%    | X/10  | X.X      |
| Functional Correctness| 20%    | X/10  | X.X      |
| UX Flows              | 10%    | X/10  | X.X      |
| Performance           | 10%    | X/10  | X.X      |
| Content Accuracy      | 10%    | X/10  | X.X      |
| Accessibility         | 15%    | X/10  | X.X      |

## Issues (N total: X critical, X major, X minor, X cosmetic)

[Issue reports from Phase 4, ordered by severity]

## Test Matrix

| Test Case                | Status | Notes          |
|--------------------------|--------|----------------|
| [description]            | PASS   |                |
| [description]            | FAIL   | See issue #N   |
| [description]            | SKIP   | [reason]       |

## Recommendations
[Top 3 prioritized actions]
```

---

## Framework-Specific Guidance

### Swift / SwiftUI
- Run `swift test` and parse `.xcresult` bundles for failures.
- Check for `@MainActor` misuse and concurrency warnings.
- Verify `Previews` compile and render without crash.
- Test both light and dark `ColorScheme`.

### React / Next.js
- Run `npm test` or `vitest`. Check for act() warnings.
- Verify hydration mismatches in SSR output.
- Check bundle size with `next build` output.
- Test with JavaScript disabled for progressive enhancement.

### Rust
- Run `cargo test` and `cargo clippy`. Treat clippy warnings as minor issues.
- Check for `unwrap()` in non-test code (flag as concern).
- Verify `unsafe` blocks have safety comments.
- Run `cargo audit` for known vulnerabilities.

### Python
- Run `pytest` with coverage. Flag < 70% coverage as concern.
- Check for type errors with `mypy` if configured.
- Verify no `print()` debug statements in production code.
- Check for pinned dependency versions.

---

## Stop Conditions

- **Build fails:** Report build failure as critical issue. Skip categories 3-7. Still test 1, 2, 8 where possible.
- **No test suite exists:** Score category 4 as 0/10. Flag as critical. Provide skeleton test file as suggested fix.
- **Regression mode with no baseline:** Fall back to `quick` mode. Warn the user.
- **Scope is a single file:** Skip categories 2, 3, 5. Adjust weights proportionally.

## Escalation Rules

- **2+ critical findings:** Immediately surface a summary before completing the full report.
- **Health score < 40:** Recommend halting feature work until score improves above 60.
- **Security finding (XSS, injection, auth bypass):** Flag as critical regardless of category. Recommend immediate review.
