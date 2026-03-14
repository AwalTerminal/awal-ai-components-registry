# Engineering Retrospective

Analyze git history to produce a structured engineering retrospective for a configurable time window. Output quantitative metrics, per-contributor breakdowns, anti-pattern flags, and a tweetable summary. Optionally save JSON snapshots for trend tracking across periods.

## Invocation

```
/retro [window] [--team] [--save] [--compare]
```

| Argument    | Default | Description                                      |
|-------------|---------|--------------------------------------------------|
| `window`    | `7d`    | Time window: `24h`, `7d`, `14d`, `30d`           |
| `--team`    | off     | Include per-contributor breakdowns                |
| `--save`    | off     | Write JSON snapshot to `.retro/` for trending     |
| `--compare` | off     | Compare current period against the previous one   |

---

## Workflow

### Phase 1: Data Collection

1. Determine the time range from `window`. Calculate `START` and `END` timestamps.
2. Run git log for the range:
   ```
   git log --after=START --before=END --format='%H|%ae|%aI|%s' --numstat
   ```
3. Collect pull request data if `gh` CLI is available:
   ```
   gh pr list --state merged --search "merged:>=START" --json number,title,additions,deletions,author,mergedAt,reviews
   ```
4. Identify test files using project conventions (e.g., `*_test.*`, `*.spec.*`, `test_*.*`, `Tests/`).

**Stop condition:** If fewer than 3 commits exist in the window, report "insufficient data" and suggest a wider window. Do not fabricate metrics.

### Phase 2: Metric Computation

Compute every metric from actual git data. Never estimate or approximate.

| Metric              | Formula                                                    |
|---------------------|------------------------------------------------------------|
| Total commits       | Count of commits in range                                  |
| LOC added           | Sum of insertions across all commits                       |
| LOC removed         | Sum of deletions across all commits                        |
| Net LOC             | Added - Removed                                            |
| Test ratio          | (test file LOC changes) / (total LOC changes)              |
| Fix ratio           | Commits matching `fix|bug|patch|hotfix` / total commits    |
| Avg PR size         | Mean (additions + deletions) per merged PR                 |
| Median PR size      | Median (additions + deletions) per merged PR               |
| Hotspot files       | Top 5 files by commit frequency                            |
| Session count       | Clusters of commits with < 2h gaps per contributor         |
| Avg session length  | Mean duration of detected sessions                         |
| Churn rate          | Lines modified in files touched more than 3 times          |

### Phase 3: Anti-Pattern Detection

Flag each pattern with severity (warning / concern / info) and cite specific evidence.

| Anti-Pattern              | Detection Rule                                              | Severity |
|---------------------------|-------------------------------------------------------------|----------|
| Commit churn              | Same file modified in 4+ commits within 24h by one author  | warning  |
| Giant PRs                 | PR with > 500 LOC changed                                  | warning  |
| Skipped tests             | Commits touching `src/` with zero corresponding test changes| concern  |
| Weekend work              | > 20% of commits on Saturday/Sunday                        | concern  |
| Drive-by fixes            | Commits touching 10+ unrelated files                       | info     |
| Abandoned PRs             | PRs open > 7 days with no review activity                  | warning  |
| Review bottleneck         | Single reviewer on > 60% of merged PRs                     | concern  |
| Late-night commits        | > 15% of commits between 22:00-06:00 local time            | info     |

**Required:** Each flag must include the specific commits, files, or PRs that triggered it. Never flag without evidence.

### Phase 4: Team Breakdown (if `--team`)

For each contributor, produce:

```
### @username
- Commits: N | LOC: +A / -R | Test ratio: X%
- Top files: file1.ext (N commits), file2.ext (N commits)
- Sessions: N (avg Xh Ym)
- Highlight: [one specific positive contribution, citing commit hash]
```

**Rules for highlights:**
- Must reference an actual commit hash and describe what it accomplished.
- Prefer: large refactors that reduced complexity, thorough test additions, critical bug fixes.
- Never fabricate praise. If a contributor only had trivial commits, describe them accurately.

### Phase 5: Trend Comparison (if `--compare`)

Compare current period metrics against the immediately preceding period of equal length.

```
| Metric         | Previous | Current | Delta   | Trend |
|----------------|----------|---------|---------|-------|
| Commits        | 42       | 38      | -9.5%   | -->   |
| Test ratio     | 0.18     | 0.31    | +72.2%  | UP    |
| Fix ratio      | 0.45     | 0.22    | -51.1%  | UP    |
| Avg PR size    | 320      | 180     | -43.8%  | UP    |
```

Trend interpretation:
- **UP** = metric moved in a healthy direction
- **DOWN** = metric moved in an unhealthy direction
- **-->** = within 10% of previous (stable)

For fix ratio, a decrease is healthy (fewer bugs). For test ratio, an increase is healthy.

### Phase 6: Output

#### Tweetable Summary (always produced, max 280 chars)

```
Week of Mar 7: 38 commits by 4 devs. Test ratio up 72% to 0.31. PR sizes down 44%. 2 churn warnings on auth module. Highlight: @alice's payment refactor (-800 LOC, +tests).
```

#### Detailed Breakdown

```markdown
# Retrospective: [START] to [END]

## Summary
[tweetable summary]

## Metrics
[table from Phase 2]

## Anti-Patterns
[flagged items from Phase 3, grouped by severity]

## Team Breakdown (if --team)
[per-contributor sections from Phase 4]

## Trends (if --compare)
[comparison table from Phase 5]

## Recommendations
[top 3 actionable items derived from the data]
```

### Phase 7: JSON Snapshot (if `--save`)

Write to `.retro/YYYY-MM-DD.json`:

```json
{
  "period": { "start": "ISO8601", "end": "ISO8601", "window": "7d" },
  "metrics": { "commits": 38, "loc_added": 2100, "loc_removed": 1400, ... },
  "anti_patterns": [ { "type": "commit_churn", "severity": "warning", "evidence": [...] } ],
  "contributors": [ { "email": "...", "commits": 12, ... } ]
}
```

---

## Scoring Rubric (self-evaluation)

Rate the retrospective output before delivering:

| Criterion               | Weight | Score 0             | Score 1                  | Score 2                    |
|-------------------------|--------|---------------------|--------------------------|----------------------------|
| Data accuracy           | 30%    | Metrics not from git| Some estimated           | All from actual git data   |
| Evidence-backed flags   | 25%    | Flags without proof | Some flags have evidence | Every flag cites evidence  |
| Actionable recs         | 20%    | Generic advice      | Relevant but vague       | Specific, data-driven      |
| Completeness            | 15%    | Missing sections    | All sections present     | Sections + trends/team     |
| Tweetable summary       | 10%    | Missing or > 280ch  | Present but generic      | Specific, punchy, accurate |

**Minimum passing score: 1.5 weighted average.** If below, re-run analysis before outputting.

---

## Stop Conditions

- **No git history in range:** Report error, suggest wider window. Do not output empty metrics.
- **No `gh` CLI:** Skip PR metrics, note absence in output. Do not fail.
- **Mono-contributor repo with `--team`:** Produce single contributor section, skip comparative language.
- **Snapshot file exists for date:** Warn and append `_N` suffix. Never overwrite.
