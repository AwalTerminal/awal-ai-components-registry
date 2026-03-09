# Awal Skills Registry

Shared AI skills registry for [Awal Terminal](https://github.com/AwalTerminal/Awal-terminal). Skills are automatically loaded based on your project type and injected into AI sessions (Claude, Gemini, Codex).

## Structure

```
registry.toml              # Stack detection rules
common/                    # Skills loaded for ALL projects
  skills/
    code-review/SKILL.md
    testing/SKILL.md
  commands/
    deploy.md
stacks/
  go/                      # Go-specific skills
  flutter/                 # Flutter-specific skills
  swift/                   # Swift-specific skills
  python/                  # Python-specific skills
  csharp/                  # C#/.NET-specific skills
  rust/                    # Rust-specific skills
  node/                    # Node.js-specific skills
  java/                    # Java-specific skills
```

## Setup

Add this registry in Awal Terminal preferences (Skills tab), or manually in `~/.config/awal/config.toml`:

```toml
[skills]
enabled = true
auto_detect = true

[skills.registry.awal-skills]
url = "https://github.com/AwalTerminal/awal-skills-registry.git"
branch = "main"
```

## How It Works

1. Awal detects your project type by scanning for marker files (e.g., `go.mod` for Go, `pubspec.yaml` for Flutter)
2. Common skills are loaded for all projects
3. Stack-specific skills are loaded based on detected project type
4. Skills are injected into the AI session before launch:
   - **Claude**: via the plugin system
   - **Gemini**: via `--system-instruction-file`
   - **Codex**: via `--instructions`

## Contributing

Add a `SKILL.md` file inside a named directory under `common/skills/` or `stacks/<stack>/skills/`. Commands go into `commands/` as standalone `.md` files.
