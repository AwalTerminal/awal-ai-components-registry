# Awal AI Components Registry

Shared AI components registry for [Awal Terminal](https://github.com/AwalTerminal/Awal-terminal). Components (skills, rules, prompts, agents) are automatically loaded based on your project type and injected into AI sessions (Claude, Gemini, Codex).

## Structure

```
registry.toml              # Stack detection rules
common/                    # Components loaded for ALL projects
  skills/
    code-review/SKILL.md   # Code review guidelines
    testing/SKILL.md        # Testing best practices
  rules/
    clean-code.md           # Clean code conventions
    security.md             # Security rules
  prompts/
    explain.md              # Explain code prompt
    optimize.md             # Optimization analysis prompt
  commands/
    deploy.md               # Deployment checklist
  agents/
    refactor/agent.json     # Refactoring agent
stacks/
  swift/                   # Swift-specific components
  rust/                    # Rust-specific components
  go/                      # Go-specific components
  flutter/                 # Flutter-specific components
  python/                  # Python-specific components
  node/                    # Node.js-specific components
  java/                    # Java-specific components
  kotlin/                  # Kotlin-specific components
  php/                     # PHP-specific components
  ruby/                    # Ruby-specific components
  csharp/                  # C#/.NET-specific components
  zig/                     # Zig-specific components
  elixir/                  # Elixir-specific components
  cpp/                     # C++-specific components
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

1. Awal detects your project type by scanning for marker files (e.g., `Cargo.toml` for Rust, `composer.json` for PHP)
2. Common components are loaded for all projects (rules, prompts, skills)
3. Stack-specific components are loaded based on detected project type
4. Components are injected into the AI session before launch:
   - **Claude**: via the plugin system (skills, rules, agents, MCP servers, hooks)
   - **Gemini**: via `--system-instruction-file` (rules, skills, prompts combined into markdown)
   - **Codex**: via `--instructions` (same combined markdown)

## Component Types

| Type | Directory | Format | Description |
|------|-----------|--------|-------------|
| Skills | `skills/<name>/SKILL.md` | Markdown | Detailed expertise on a topic |
| Rules | `rules/<name>.md` | Markdown | Coding conventions and constraints |
| Prompts | `prompts/<name>.md` | Markdown | Reusable prompt templates (slash commands) |
| Agents | `agents/<name>/agent.json` | JSON | Agent definitions with tools and instructions |
| Commands | `commands/<name>.md` | Markdown | Task checklists and procedures |
| MCP Servers | `mcp-servers/<name>.json` | JSON | MCP server configurations (Claude only) |
| Hooks | `hooks/{pre,post}-session/<name>.sh` | Shell | Scripts run before/after AI sessions |

## Contributing

1. Add components under `common/` (for all projects) or `stacks/<stack>/` (for specific stacks)
2. Follow the directory structure conventions above
3. Keep content concise and actionable — AI models work best with clear, specific instructions
4. Test by adding this repo as a registry in Awal Terminal and verifying components load
