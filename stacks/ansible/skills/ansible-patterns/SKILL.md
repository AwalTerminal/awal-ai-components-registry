# Ansible Patterns

## Playbook Design
- Keep playbooks high-level — delegate implementation details to roles
- Use `become: true` only when tasks require elevated privileges
- Use `tags` on tasks and roles for selective execution
- Group related tasks into blocks with shared `when` conditions and error handling
- Use `handlers` for service restarts — `notify` from tasks, don't restart inline

## Roles and Reusability
- Follow the standard role directory structure: `tasks/`, `handlers/`, `defaults/`, `vars/`, `templates/`
- Use `defaults/main.yml` for overridable variables, `vars/main.yml` for internal constants
- Keep roles focused — one role per service or concern
- Use `ansible-galaxy` to share and consume community roles
- Pin role versions in `requirements.yml`

## Variables and Secrets
- Use Ansible Vault for secrets: `ansible-vault encrypt_string`
- Follow a clear variable precedence — prefer `group_vars/` and `host_vars/` directories
- Use `default` filter in templates for optional variables: `{{ var | default('fallback') }}`
- Prefix role variables with the role name to avoid collisions: `nginx_port`, `nginx_root`

## Idempotency
- Ensure every task is idempotent — running the playbook twice should produce the same result
- Use module-specific parameters instead of `shell`/`command` when possible
- Use `creates` and `removes` parameters on `command`/`shell` tasks to skip when unnecessary
- Test idempotency by running the playbook twice and checking for zero changes

## Inventory
- Use dynamic inventory scripts or plugins for cloud environments
- Organize hosts into groups by environment, role, and region
- Use `group_vars/` directories matching inventory group names
- Use `ansible_host` for connection addresses, meaningful names for host aliases
