# Ansible Style and Security Rules

## Task Formatting

- Name every task with a descriptive, action-oriented `name` field — never leave tasks unnamed
- Use fully qualified collection names (FQCN) for all modules: `ansible.builtin.copy`, not `copy`
- Use YAML dictionary syntax for task parameters — never use the `key=value` shorthand
- Keep task names concise but descriptive: "Install nginx packages", not "This task installs the nginx web server"
- Use present tense imperative mood: "Ensure service is running", "Deploy configuration file"

```yaml
# GOOD
- name: Install required packages
  ansible.builtin.apt:
    name: "{{ required_packages }}"
    state: present
    update_cache: true

# BAD — unnamed, shorthand syntax, no FQCN
- apt: name=nginx state=present
```

## Variable Conventions

- Use `snake_case` for all variable names, role names, and file names
- Prefix role variables with the role name: `nginx_port`, `postgres_data_dir`
- Use `defaults/main.yml` for variables users should override; `vars/main.yml` for internal constants
- Use the `default` filter for optional variables: `{{ optional_var | default('fallback') }}`
- Never use `set_fact` for values that should be in inventory or role defaults — `set_fact` has high precedence and bypasses the variable hierarchy
- Document variables with comments in defaults files explaining type and purpose

## File and Directory Naming

- Name playbook files descriptively: `deploy-api.yml`, `setup-monitoring.yml`
- Use `site.yml` as the master playbook that includes all others
- Name inventory directories by environment: `inventory/production/`, `inventory/staging/`
- Keep `group_vars/` and `host_vars/` directories adjacent to the inventory file
- Name template files with `.j2` extension: `nginx.conf.j2`

## Linting and Validation

- Run `ansible-lint` on all playbooks and roles before committing — fix all warnings
- Configure `ansible-lint` with a `.ansible-lint` file at the project root
- Run `yamllint` for YAML syntax validation
- Run `ansible-playbook --syntax-check` to catch parse errors
- Use `--check --diff` (dry-run mode) before applying changes to production
- Integrate linting into CI — fail the pipeline on lint violations

```yaml
# .ansible-lint
---
profile: production
strict: true
skip_list:
  - role-name  # Only skip rules with documented justification
warn_list:
  - experimental
```

## Security Rules

### Vault and Secrets
- Encrypt all files containing secrets with `ansible-vault`
- Use `no_log: true` on every task that handles secret values — prevents secrets from appearing in stdout
- Use the `vault_` prefix convention: encrypted values in `vault.yml`, referenced via plain variables in `common.yml`
- Store the vault password file outside the repository — reference via `--vault-password-file` or `ANSIBLE_VAULT_PASSWORD_FILE`
- Use vault IDs to separate secret scopes: `--vault-id dev@prompt`, `--vault-id prod@file`
- Rotate vault passwords periodically — re-encrypt all vaulted files after rotation

```yaml
# GOOD: Secret handling with no_log
- name: Set database password
  ansible.builtin.lineinfile:
    path: /etc/app/db.conf
    regexp: "^DB_PASSWORD="
    line: "DB_PASSWORD={{ db_password }}"
    mode: "0600"
    owner: appuser
  no_log: true
```

### Privilege Escalation
- Use `become: true` only on tasks that require root — not at the play level unless every task needs it
- Set `become_method: sudo` explicitly
- Use `become_user` when escalating to a specific non-root user
- Limit sudoers configuration to only the commands Ansible needs
- Never use `become: true` with `ansible.builtin.shell` unless absolutely necessary — prefer specific modules

### Connection Security
- Use SSH key-based authentication — never store SSH passwords in inventory
- Disable SSH password authentication on managed hosts
- Use SSH agent forwarding or `ansible_ssh_private_key_file` for key management
- Configure `host_key_checking = true` in production (only disable in ephemeral test environments)
- Use `ansible.cfg` to set secure defaults:

```ini
[defaults]
host_key_checking = true
retry_files_enabled = false
no_log = false

[privilege_escalation]
become_ask_pass = false
```

## Idempotency Rules

- Every task must be idempotent — running the playbook twice produces zero changes on the second run
- Use dedicated modules over `shell`/`command` whenever possible
- When `shell`/`command` is unavoidable, always use `creates`, `removes`, or `when` conditions
- Set `changed_when` on command tasks to accurately report change status
- Verify idempotency by running the playbook twice in CI and asserting zero changes on the second run

## Error Handling Rules

- Never use `ignore_errors: true` — use `failed_when` with specific conditions instead
- Use `block/rescue/always` for operations that need rollback on failure
- Use `register` and `failed_when` to define custom failure conditions
- Use `any_errors_fatal: true` at the play level for operations that must succeed on all hosts
- Set `max_fail_percentage` when partial failure is acceptable (e.g., rolling updates)

```yaml
# GOOD: Specific failure condition
- name: Check application health
  ansible.builtin.uri:
    url: "http://localhost:8080/health"
    status_code: 200
  register: health_result
  failed_when: health_result.status != 200
  retries: 5
  delay: 3
  until: health_result.status == 200
```

## Playbook Organization

- Keep playbooks under 100 lines — extract complex logic into roles
- Use `import_playbook` for composing multiple playbooks into a site-wide run
- Use `include_role` for conditional role inclusion at runtime
- Use `import_role` for static inclusion (parsed at playbook load time)
- Group related tasks in `block` with shared `when` conditions
- Use tags consistently for selective execution: `tags: [deploy, app]`

## Inventory Rules

- Use YAML format for inventory files — not INI format
- Use dynamic inventory plugins for cloud environments — static inventory for bare metal
- Group hosts by function, environment, and region
- Never hardcode IP addresses in playbooks — use inventory variables
- Use `ansible_host` for connection addresses, meaningful names for host aliases
- Test connectivity before every deployment: `ansible all -m ping`
