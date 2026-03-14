# Awal AI Components Registry

Production-quality AI components for [Awal Terminal](https://github.com/AwalTerminal/Awal-terminal). Components are automatically loaded based on your project's tech stack and injected into AI sessions (Claude, Gemini, Codex).

Every skill has concrete checklists, output format specs, stop conditions, and anti-patterns — not vague guidelines. Inspired by [gstack](https://github.com/garrytan/gstack).

## Common Components

Loaded for **all** projects regardless of stack.

### Skills

| Skill | Description |
|-------|-------------|
| `/review` | Two-pass code review — Pass 1 flags critical/blocking issues (injection, auth bypass, race conditions, data corruption, secret exposure), Pass 2 flags informational items (magic numbers, dead code, naming). Output: `file:line` with severity and suggested fix. Read-only by default. |
| `/ship` | Automated release pipeline — detects test runner from project markers, runs tests, generates changelog from commits, bumps version (semver/calver), tags, pushes, creates GitHub release. Stops on test failure, merge conflict, or critical review finding. |
| `/plan` | Architecture review in two modes — **Product Review** challenges premises and explores the 10-star experience; **Engineering Review** covers 10 sections (architecture, error map, security, data flows, code quality, testing, performance, observability, deployment, trajectory). Outputs ASCII diagrams, decision matrices with effort/risk/maintenance tradeoffs. |
| `/retro` | Engineering retrospective from git history — configurable time windows (24h–30d), computes metrics (commits, LOC, test ratio, PR sizes, fix ratio, hotspot files), per-contributor breakdowns with praise anchored to actual commits, trend comparison, tweetable summary. |
| `/qa` | Quality assurance with 3 modes (full/quick/regression) — scores health across 8 weighted categories (console errors, broken links, visual regression, functional correctness, UX flows, performance, content accuracy, accessibility). Every finding requires evidence and structured repro steps. |

### Prompts

| Prompt | Description |
|--------|-------------|
| `/explain` | Structured code explanation at 3 depth levels (overview, detailed, deep-dive) — purpose, mechanism, data flow with ASCII diagrams, dependencies, edge cases, complexity analysis. |
| `/optimize` | Profiling-first performance optimization — 5 categories (algorithmic, I/O, memory, concurrency, caching), each with anti-pattern checklists. Requires before/after complexity, estimated impact, and tradeoff analysis. |

### Rules

| Rule | Description |
|------|-------------|
| `clean-code` | Complexity thresholds (cyclomatic ≤10, function ≤40 lines, params ≤4), naming conventions table, DRY vs WET guidance, concrete anti-patterns with before/after examples, dead code detection. |
| `security` | OWASP Top 10 with detection patterns, trust boundary analysis, secrets detection regex (API keys, AWS, JWT, etc.), supply chain checklist, auth/authz patterns, HTTP security headers, file upload rules. |

### Agents

| Agent | Description |
|-------|-------------|
| `refactor` | 12 named refactoring patterns (Extract Method, Replace Conditional with Polymorphism, Introduce Parameter Object, etc.) with complexity reduction targets. Preserves tests, confirms before changing public API. |
| `debug` | Systematic methodology: reproduce → isolate → identify → fix → verify. Includes binary search/wolf fence, git bisect guidance, root cause analysis template, hypothesis testing protocol. |

## Stack Coverage

35 stacks organized by depth of coverage. Every stack includes **patterns** (idiomatic code, concurrency, error handling, performance, pitfalls), **style rules** (naming, file structure, conventions), and **commands** (build, test, lint, format).

### Tier 1 — Deeply detailed (200–400+ lines per skill)

| Stack | Detect | Highlights |
|-------|--------|------------|
| Swift | `Package.swift`, `*.xcodeproj`, `*.xcworkspace` | Protocol-oriented programming, async/await + actors + structured concurrency, ARC/weak/unowned, Result builders, property wrappers, COW performance |
| Rust | `Cargo.toml` | Ownership/borrowing/lifetimes, trait system, thiserror/anyhow, Send/Sync + tokio + rayon, unsafe guidelines, macro patterns, zero-cost abstractions |
| Go | `go.mod`, `go.sum` | Interfaces, error wrapping/sentinels, context propagation, goroutine patterns (fan-in/out, pipeline, worker pool), sync primitives, escape analysis, pprof |
| Python | `pyproject.toml`, `setup.py`, `requirements.txt`, `uv.lock` | Type hints (TypeVar, Protocol), dataclasses, context managers, generators, decorators (ParamSpec), asyncio TaskGroup, GIL implications, profiling |
| TypeScript | `tsconfig.json` | Conditional/mapped/template literal types, branded types, `satisfies`, discriminated unions, Result pattern, AbortController, tree-shaking. Also includes **React patterns**: hooks, component composition, state management, React.memo, Suspense, RTL testing |
| Java | `pom.xml`, `build.gradle`, `build.gradle.kts` | Records, sealed classes, virtual threads (Loom), Stream API, CompletableFuture, concurrent collections, JVM tuning, JMH, Spring patterns |
| Kotlin | `build.gradle.kts`, `*.kt` | Null safety, coroutines (structured concurrency, Flow, StateFlow/SharedFlow), sealed classes, delegation, inline/value classes, sequence vs collection |
| Dart | `pubspec.yaml`, `*.dart` | Sound null safety, extension types, sealed classes + exhaustive matching, Isolates, Streams, const constructors, AOT vs JIT |

### Tier 2 — Solid coverage (150–250 lines per skill)

| Stack | Detect | Highlights |
|-------|--------|------------|
| PHP | `composer.json`, `artisan` | PHP 8.x (enums, fibers, readonly, match), PSR standards, DI/repository pattern, Laravel/Symfony, OPcache/JIT, PHPUnit/Pest |
| Ruby | `Gemfile`, `*.gemspec`, `Rakefile` | Blocks/procs/lambdas, metaprogramming, Enumerable, pattern matching, Rails patterns, Ractor/Sidekiq, RSpec/FactoryBot |
| C# | `*.csproj`, `*.sln` | LINQ, async/await + IAsyncEnumerable + ValueTask, records, pattern matching, Span\<T\>, source generators, EF patterns, xUnit |
| C++ | `CMakeLists.txt`, `*.cpp`, `*.hpp` | C++17/20/23 (concepts, ranges, coroutines, modules, std::expected), smart pointers/RAII, move semantics, atomics, constexpr, CMake |
| Scala | `build.sbt`, `*.scala` | Type classes, higher-kinded types, pattern matching + extractors, for-comprehensions, Futures, ZIO patterns, ScalaTest/ScalaCheck |
| Elixir | `mix.exs` | OTP (GenServer, Supervisor), pattern matching, pipelines, protocols, Task/Agent, Phoenix LiveView, Ecto, ETS, ExUnit/Mox |
| Zig | `build.zig` | Comptime, error unions/errdefer, allocator patterns (arena, GPA), packed structs, C interop, build.zig patterns |

### Tier 3 — Essential patterns (100–200 lines per skill)

| Stack | Detect | Highlights |
|-------|--------|------------|
| Haskell | `*.cabal`, `stack.yaml` | Type classes, monads, lens/optics, STM/async, strictness/bang patterns, HSpec/QuickCheck |
| Clojure | `project.clj`, `deps.edn` | Immutable data, transducers, protocols/multimethods, spec, core.async, REPL-driven dev |
| OCaml | `dune-project`, `*.opam` | Modules/functors, GADTs, effects (OCaml 5), Lwt/Domains, Dune |
| F# | `*.fsproj`, `*.fsx` | Discriminated unions, computation expressions, active patterns, railway-oriented programming, MailboxProcessor |
| R | `DESCRIPTION`, `*.Rproj` | Tidyverse, vectorization, purrr, S3/R6, data.table, Rcpp, testthat |
| Julia | `Project.toml`, `*.jl` | Multiple dispatch, type stability, metaprogramming, broadcasting, SIMD, JET.jl |
| Perl | `cpanfile`, `Makefile.PL`, `dist.ini` | Moo/Moose, regex mastery, CPAN patterns, Test2 |
| Lua | `*.rockspec`, `.luacheckrc` | Metatables, coroutines, environments, LuaJIT FFI, busted |
| Objective-C | `*.m`, `*.mm`, `Podfile` | ARC, blocks, protocols/delegates, categories, KVO/KVC, Swift interop |
| Shell | `*.sh`, `*.bash`, `.shellcheckrc` | `set -euo pipefail`, parameter expansion, process substitution, trap/signals, bats-core |

### Frameworks

| Stack | Detect | Highlights |
|-------|--------|------------|
| Flutter | `pubspec.yaml` | Widget composition, Riverpod/Bloc, GoRouter, RepaintBoundary, golden tests, platform channels. Includes pre/post-session hooks. |
| Svelte | `svelte.config.js`, `*.svelte` | Svelte 5 runes ($state, $derived, $effect), SvelteKit load/form actions/hooks, Vitest + Playwright |
| Vue | `vue.config.js`, `*.vue`, `nuxt.config.ts` | Composition API, ref vs reactive, composables, Nuxt useAsyncData/server routes, v-memo, Vue Test Utils |
| Angular | `angular.json`, `ng-package.json` | Signals, standalone components, RxJS patterns, reactive forms, OnPush, TestBed/Spectator |
| React Native | `metro.config.js`, `app.json` | React Navigation, FlatList optimization, Reanimated, Hermes, Fabric/TurboModules, Detox E2E |
| Node.js | `package.json` | Core Node.js patterns (event loop, streams, clustering) |

### DevOps / Infrastructure

| Stack | Detect | Highlights |
|-------|--------|------------|
| Terraform | `*.tf`, `*.tfvars` | Module design, state management (remote backends, workspaces), for_each vs count, drift detection, terratest |
| Docker | `Dockerfile`, `docker-compose.yml`, `compose.yaml` | Multi-stage builds, layer optimization, non-root/distroless, BuildKit secrets, multi-platform, vulnerability scanning |
| Kubernetes | `kustomization.yaml`, `helmfile.yaml`, `Chart.yaml` | Resource management (QoS), network policies, RBAC, sealed secrets, Helm charts, HPA/PDB, pod security standards |
| Ansible | `ansible.cfg`, `playbook.yml`, `roles/` | Role design, variable precedence, vault, idempotency, handlers, Molecule testing, dynamic inventory |

## Structure

```
registry.toml                  # Stack detection (35 stacks)
common/
  skills/
    review/SKILL.md             # Two-pass code review
    ship/SKILL.md               # Release pipeline
    plan/SKILL.md               # Architecture review
    retro/SKILL.md              # Engineering retrospective
    qa/SKILL.md                 # Quality assurance
  rules/
    clean-code.md               # Code quality thresholds
    security.md                 # OWASP-mapped security
  prompts/
    explain.md                  # Code explanation
    optimize.md                 # Performance optimization
  agents/
    refactor/agent.json         # Refactoring specialist
    debug/agent.json            # Debugging methodology
stacks/
  <stack>/
    skills/<name>/SKILL.md      # Deep patterns + code examples
    rules/<name>.md             # Style conventions
    commands/<name>.md           # Build/test/lint commands
    hooks/                      # Optional session hooks (Flutter)
```

## Setup

Pre-configured in Awal Terminal. To add manually:

```toml
# ~/.config/awal/config.toml
[ai_components]
enabled = true
auto_detect = true

[ai_components.registry.awal-components]
url = "https://github.com/AwalTerminal/awal-ai-components-registry.git"
branch = "main"
```

## How It Works

1. Awal scans for marker files (e.g., `Cargo.toml` → Rust, `tsconfig.json` → TypeScript)
2. Common components load for all projects
3. Matching stack components load based on detected markers
4. Components inject into the AI session:
   - **Claude** — plugin system (skills, rules, agents, hooks)
   - **Gemini** — `--system-instruction-file` (combined markdown)
   - **Codex** — `--instructions` (combined markdown)

## Component Types

| Type | Path | Purpose |
|------|------|---------|
| Skill | `skills/<name>/SKILL.md` | Deep expertise with checklists, output specs, stop conditions |
| Rule | `rules/<name>.md` | Conventions with anti-patterns and before/after examples |
| Prompt | `prompts/<name>.md` | Reusable prompt templates with structured output |
| Agent | `agents/<name>/agent.json` | Autonomous agents with tools and workflows |
| Command | `commands/<name>.md` | Build/test/lint/format command references |
| Hook | `hooks/{pre,post}-session/<name>.sh` | Shell scripts run before/after AI sessions |
