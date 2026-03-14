# Explain Code

Produce a structured explanation of the given code, file, or system. The explanation must be grounded in the actual code -- never speculate about behavior that isn't evidenced in the source. Adapt depth to the request, default to "detailed" if unspecified.

## Depth Levels

| Level      | Audience               | Length    | Includes                                    |
|------------|------------------------|-----------|---------------------------------------------|
| `overview` | New team member        | 1-2 pages | Purpose, inputs/outputs, key decisions      |
| `detailed` | Working developer      | 2-5 pages | + mechanism, data flow, edge cases, diagrams |
| `deep-dive`| Debugger / reviewer    | 5+ pages  | + line-by-line, complexity, alternatives     |

Specify depth with: `/explain [path] --depth overview|detailed|deep-dive`

---

## Analysis Structure

### 1. Purpose (all levels)

Answer in 1-3 sentences:
- **What** does this code accomplish?
- **Why** does it exist? What problem does it solve?
- **Where** does it fit in the larger system?

Format:
```
**Purpose:** [component name] handles [responsibility] within [system context].
It exists because [motivation]. Callers include [list primary consumers].
```

### 2. Interface (all levels)

Document the public contract:

```
**Inputs:**
- `param1: Type` -- description, valid range, default
- `param2: Type` -- description, constraints

**Outputs:**
- `ReturnType` -- description, possible values

**Side Effects:**
- [file writes, network calls, state mutations, logging]

**Errors:**
- `ErrorType1` -- when [condition]
- `ErrorType2` -- when [condition]
```

### 3. Mechanism (detailed, deep-dive)

Walk through the logic in execution order. Use numbered steps that map to code regions:

```
**Mechanism:**
1. [Lines N-M] Validate input by checking [condition]. Reject with [error] if invalid.
2. [Lines N-M] Transform data from [format A] to [format B] using [technique].
3. [Lines N-M] Dispatch to [subsystem] and await response.
4. [Lines N-M] Handle response: on success [action], on failure [recovery strategy].
```

Rules:
- Reference actual line numbers or function names.
- Identify the core algorithm or pattern (e.g., "visitor pattern", "two-pointer", "event sourcing").
- If the logic branches, describe each branch.

### 4. Data Flow (detailed, deep-dive)

**Required: produce an ASCII diagram** showing how data moves through the code.

For a function:
```
Input A ──> [Validation] ──> [Transform] ──> [Process] ──> Output B
                |                                 |
                v                                 v
            Error path                      Side effect
```

For a system/module:
```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Caller  │────>│  Module  │────>│   Dep A  │
└──────────┘     │          │────>│   Dep B  │
                 └──────────┘     └──────────┘
                      │
                      v
                 ┌──────────┐
                 │  Output  │
                 └──────────┘
```

Diagram rules:
- Use box-drawing characters for boxes, arrows for data flow.
- Label every edge with what is being passed.
- Show error/fallback paths as dashed or annotated lines.
- Keep diagrams under 40 columns wide when possible.

### 5. Dependencies (detailed, deep-dive)

```
**Depends On:**
- `module/path` -- uses [specific function/type] for [purpose]
- `external-crate v1.2` -- [what it provides]

**Depended On By:**
- `consumer/path` -- calls [function] during [workflow]
- `test/path` -- tests [specific behavior]

**Coupling Assessment:** [low | moderate | high] -- [justification]
```

### 6. Edge Cases (detailed, deep-dive)

List every edge case you can identify. For each:

```
| Edge Case              | Handling          | Location     | Adequate? |
|------------------------|-------------------|--------------|-----------|
| Empty input            | Returns default   | line 42      | Yes       |
| Concurrent access      | No synchronization| lines 50-60  | No -- race condition |
| Max size exceeded      | Silently truncates| line 78      | Risky     |
```

Flag unhandled edge cases explicitly. This is one of the most valuable parts of the explanation.

### 7. Complexity Analysis (deep-dive only)

```
**Time Complexity:** O(n log n) where n = [describe what n represents]
  - [Line/block]: O(n) -- iterates input once
  - [Line/block]: O(n log n) -- sorts intermediate results
  - Dominant term: sort at line N

**Space Complexity:** O(n) -- allocates [data structure] proportional to input size

**Scaling Concerns:**
- At 1K items: ~Xms (acceptable)
- At 100K items: ~Xms (concerning because [reason])
- At 1M items: [prediction and recommendation]
```

### 8. Design Alternatives (deep-dive only)

```
**Current approach:** [description]
**Alternative 1:** [description]
  - Pro: [advantage]
  - Con: [disadvantage]
  - When to prefer: [condition]

**Alternative 2:** [description]
  - Pro: [advantage]
  - Con: [disadvantage]
  - When to prefer: [condition]

**Verdict:** Current approach is [appropriate | suboptimal] because [reason].
```

---

## Output Templates

### Overview Output

```markdown
# [Component Name]

**Purpose:** [1-3 sentences]

## Interface
[inputs, outputs, errors]

## Key Decisions
- [Decision 1]: [why this approach was chosen]
- [Decision 2]: [why this approach was chosen]

## Quick Reference
- Entry point: `function_name` at `file:line`
- Config: `config_path`
- Tests: `test_path`
```

### Detailed Output

```markdown
# [Component Name]

**Purpose:** [1-3 sentences]

## Interface
[full interface documentation]

## How It Works
[numbered mechanism walkthrough]

## Data Flow
[ASCII diagram]

## Dependencies
[dependency map]

## Edge Cases
[edge case table]

## Key Takeaways
- [Most important thing to understand]
- [Second most important thing]
- [Non-obvious gotcha or subtlety]
```

### Deep-Dive Output

```markdown
# [Component Name] -- Deep Dive

**Purpose:** [1-3 sentences]

## Interface
[full interface documentation]

## Mechanism (Line-by-Line)
[detailed walkthrough with line references]

## Data Flow
[ASCII diagram -- potentially multiple for different paths]

## Dependencies
[dependency map with coupling assessment]

## Edge Cases & Robustness
[edge case table with adequacy ratings]

## Complexity
[time and space analysis with scaling predictions]

## Design Alternatives
[comparison of approaches]

## Risk Assessment
- [Risk 1]: likelihood [H/M/L], impact [H/M/L], mitigation [action]
- [Risk 2]: ...
```

---

## Rules

1. **Never invent behavior.** If you cannot determine what code does, say so. Quote the ambiguous section.
2. **Reference locations.** Every claim about the code must cite a file, function, or line range.
3. **Diagrams are mandatory** for `detailed` and `deep-dive` levels. Skip only if the code is a single pure function under 20 lines.
4. **Preserve jargon.** Use the codebase's own names for things. Do not rename concepts.
5. **Flag surprises.** If something behaves unexpectedly or contradicts common patterns, call it out explicitly.
6. **Adapt scope.** If asked about a single function, do not explain the entire module. If asked about a system, do not go line-by-line on every file.
