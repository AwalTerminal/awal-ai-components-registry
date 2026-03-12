# Ansible Style Rules

- Use `ansible-lint` and fix all warnings before committing
- Use YAML format for all playbooks and tasks — never use the `key=value` shorthand
- Name every task with a descriptive, human-readable `name` field
- Use `snake_case` for variable names, role names, and file names
- Use Ansible Vault for all secrets — never commit plaintext credentials
- Avoid `shell`/`command` modules when a dedicated module exists (e.g., use `apt`, `copy`, `template`)
- Keep playbooks under 100 lines — extract complex logic into roles
- Use `--check --diff` (dry-run) mode before applying changes to production
