# Awal AI Components Registry

Production-quality AI components for [Awal Terminal](https://github.com/AwalTerminal/Awal-terminal). Components (skills, rules, prompts, agents) are automatically loaded based on your project type and injected into AI sessions.

Every skill has concrete checklists, output format specs, stop conditions, and anti-patterns — not vague guidelines.

## Common Components (loaded for ALL projects)

| Component | Type | Description |
|-----------|------|-------------|
| `/review` | Skill | Two-pass code review (critical → informational) with `file:line` output |
| `/ship` | Skill | Automated release pipeline with stack-aware test detection |
| `/plan` | Skill | Architecture review with product + engineering modes |
| `/retro` | Skill | Engineering retrospective from git history with metrics |
| `/qa` | Skill | Quality assurance with 8-category health scoring rubric |
| `/explain` | Prompt | Structured code explanation with 3 depth levels |
| `/optimize` | Prompt | Profiling-first performance optimization |
| `clean-code` | Rule | Complexity thresholds, naming conventions, anti-patterns |
| `security` | Rule | OWASP Top 10 mapping, secrets detection, trust boundaries |
| `refactor` | Agent | Named refactoring patterns with complexity reduction targets |
| `debug` | Agent | Systematic debugging: reproduce → isolate → identify → fix → verify |

## Stack Coverage (35 stacks)

### Tier 1 — Deeply detailed
| Stack | Detect | Components |
|-------|--------|------------|
| Swift | `Package.swift`, `*.xcodeproj` | patterns, style, commands |
| Rust | `Cargo.toml` | patterns, style, commands |
| Go | `go.mod`, `go.sum` | patterns, style, commands |
| Python | `pyproject.toml`, `setup.py`, `requirements.txt` | patterns, style, commands |
| TypeScript | `tsconfig.json` | patterns, react-patterns, style, commands |
| Java | `pom.xml`, `build.gradle` | patterns, style, commands |
| Kotlin | `build.gradle.kts`, `*.kt` | patterns, style, commands |
| Dart | `pubspec.yaml`, `*.dart` | patterns, style, commands |

### Tier 2 — Solid coverage
| Stack | Detect | Components |
|-------|--------|------------|
| PHP | `composer.json`, `artisan` | patterns, style, commands |
| Ruby | `Gemfile`, `*.gemspec` | patterns, style, commands |
| C# | `*.csproj`, `*.sln` | patterns, style, commands |
| C++ | `CMakeLists.txt` | patterns, style, commands |
| Scala | `build.sbt` | patterns, style, commands |
| Elixir | `mix.exs` | patterns, style, commands |
| Zig | `build.zig` | patterns, style, commands |

### Tier 3 — Essential patterns
Haskell, Clojure, OCaml, F#, R, Julia, Perl, Lua, Objective-C, Shell/Bash

### Frameworks
| Stack | Detect | Components |
|-------|--------|------------|
| Flutter | `pubspec.yaml` | patterns, style, commands, hooks |
| Svelte | `svelte.config.js`, `*.svelte` | patterns, style, commands |
| Vue | `vue.config.js`, `*.vue`, `nuxt.config.ts` | patterns, style, commands |
| Angular | `angular.json` | patterns, style, commands |
| React Native | `metro.config.js`, `app.json` | patterns, style, commands |
| Node.js | `package.json` | patterns |

### DevOps / Infrastructure
| Stack | Detect | Components |
|-------|--------|------------|
| Terraform | `*.tf`, `*.tfvars` | patterns, style, commands |
| Docker | `Dockerfile`, `compose.yaml` | patterns, style, commands |
| Kubernetes | `kustomization.yaml`, `Chart.yaml` | patterns, style, commands |
| Ansible | `ansible.cfg`, `playbook.yml` | patterns, style, commands |

## Structure

```
registry.toml              # Stack detection rules (35 stacks)
common/                    # Components loaded for ALL projects
  skills/
    review/SKILL.md        # Two-pass code review
    ship/SKILL.md          # Automated release pipeline
    plan/SKILL.md          # Architecture review
    retro/SKILL.md         # Engineering retrospective
    qa/SKILL.md            # Quality assurance testing
  rules/
    clean-code.md          # Code quality with complexity thresholds
    security.md            # OWASP-mapped security rules
  prompts/
    explain.md             # Structured code explanation
    optimize.md            # Performance optimization
  agents/
    refactor/agent.json    # Refactoring specialist
    debug/agent.json       # Systematic debugging
stacks/                    # Stack-specific components (35 stacks)
  <stack>/
    skills/<stack>-patterns/SKILL.md
    rules/<stack>-style.md
    commands/<stack>.md
```

## Setup

This registry is pre-configured in Awal Terminal. You can also add it manually in `~/.config/awal/config.toml`:

```toml
[ai_components]
enabled = true
auto_detect = true

[ai_components.registry.awal-components]
url = "https://github.com/AwalTerminal/awal-ai-components-registry.git"
branch = "main"
```

## How It Works

1. Awal detects your project type by scanning for marker files (e.g., `Cargo.toml` → Rust)
2. Common components are loaded for all projects
3. Stack-specific components are loaded based on detected stacks
4. Components are injected into the AI session:
   - **Claude**: via the plugin system (skills, rules, agents, MCP servers, hooks)
   - **Gemini**: via `--system-instruction-file` (combined markdown)
   - **Codex**: via `--instructions` (combined markdown)

## Component Types

| Type | Path | Description |
|------|------|-------------|
| Skills | `skills/<name>/SKILL.md` | Detailed expertise with checklists & output specs |
| Rules | `rules/<name>.md` | Coding conventions with anti-patterns |
| Prompts | `prompts/<name>.md` | Reusable prompt templates |
| Agents | `agents/<name>/agent.json` | Agent definitions with tools and workflows |
| Commands | `commands/<name>.md` | Build/test/lint command references |
| Hooks | `hooks/{pre,post}-session/<name>.sh` | Scripts run before/after AI sessions |

## Quality Bar

Every component in this registry meets these standards:

- **Skills**: Concrete checklists, output format specs, stop conditions, anti-patterns
- **Rules**: Specific examples with before/after, not just guidelines
- **Stack patterns**: Idiomatic code examples, concurrency/error handling patterns, common pitfalls
- **Commands**: Actual commands with flags, not just tool names
