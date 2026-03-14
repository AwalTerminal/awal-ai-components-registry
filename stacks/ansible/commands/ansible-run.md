# Ansible Run, Test, and Operations

## Playbook Execution

```bash
# Run a playbook
ansible-playbook playbook.yml

# Run with a specific inventory
ansible-playbook -i inventory/production/hosts.yml playbook.yml

# Limit to specific hosts or groups
ansible-playbook playbook.yml -l webservers
ansible-playbook playbook.yml -l "webservers:&production"
ansible-playbook playbook.yml -l "web01.example.com"

# Run specific tags only
ansible-playbook playbook.yml -t deploy
ansible-playbook playbook.yml -t "deploy,configure"

# Skip specific tags
ansible-playbook playbook.yml --skip-tags "install"

# Dry-run with diff output (check mode)
ansible-playbook playbook.yml --check --diff

# Verbose output (levels: -v, -vv, -vvv, -vvvv)
ansible-playbook playbook.yml -vv

# Pass extra variables (highest precedence)
ansible-playbook playbook.yml -e "app_version=1.2.3 deploy_env=staging"

# Pass extra variables from a JSON file
ansible-playbook playbook.yml -e "@vars/deploy-config.json"

# Limit parallelism (run on 5 hosts at a time)
ansible-playbook playbook.yml --forks=5

# Step through tasks one at a time (interactive)
ansible-playbook playbook.yml --step

# Start at a specific task
ansible-playbook playbook.yml --start-at-task="Deploy application"

# Prompt for vault password
ansible-playbook playbook.yml --ask-vault-pass

# Use a vault password file
ansible-playbook playbook.yml --vault-password-file=~/.vault_pass
```

## Vault Operations

```bash
# Encrypt a file
ansible-vault encrypt secrets.yml

# Decrypt a file (for editing, then re-encrypt)
ansible-vault decrypt secrets.yml

# Edit an encrypted file in-place (decrypts, opens editor, re-encrypts)
ansible-vault edit secrets.yml

# View encrypted file contents without decrypting to disk
ansible-vault view secrets.yml

# Encrypt a single string (for inline vault values)
ansible-vault encrypt_string 'my_secret_value' --name 'vault_db_password'

# Re-key (change the vault password)
ansible-vault rekey secrets.yml

# Encrypt with a specific vault ID
ansible-vault encrypt --vault-id prod@prompt secrets.yml

# Re-key with vault IDs
ansible-vault rekey --vault-id old@old_pass --new-vault-id new@new_pass secrets.yml

# Use multiple vault IDs in a playbook run
ansible-playbook site.yml \
  --vault-id dev@dev-vault-pass.txt \
  --vault-id prod@prod-vault-pass.txt
```

## Ad-Hoc Commands

```bash
# Test connectivity to all hosts
ansible all -m ping

# Test connectivity to a specific group
ansible webservers -m ping

# Gather facts from a host
ansible web01 -m ansible.builtin.setup

# Gather specific facts
ansible web01 -m ansible.builtin.setup -a "filter=ansible_distribution*"

# Run a command on all hosts
ansible all -m ansible.builtin.command -a "uptime"

# Copy a file to all web servers
ansible webservers -m ansible.builtin.copy -a "src=./app.conf dest=/etc/app/config.yml"

# Install a package
ansible webservers -m ansible.builtin.apt -a "name=nginx state=present" --become

# Restart a service
ansible webservers -m ansible.builtin.systemd -a "name=nginx state=restarted" --become

# Check disk usage
ansible all -m ansible.builtin.command -a "df -h"
```

## Inventory Management

```bash
# Show inventory as a graph
ansible-inventory --graph

# Show inventory as a graph for a specific group
ansible-inventory --graph webservers

# List all hosts with variables
ansible-inventory --list

# Show variables for a specific host
ansible-inventory --host web01.example.com

# Validate inventory file syntax
ansible-inventory -i inventory/production/hosts.yml --list > /dev/null

# Use dynamic inventory plugin
ansible-inventory -i inventory/aws_ec2.yml --graph
```

## Galaxy and Role Management

```bash
# Install roles from requirements file
ansible-galaxy install -r requirements.yml

# Install roles to a specific path
ansible-galaxy install -r requirements.yml -p roles/

# Install a specific role from Galaxy
ansible-galaxy install geerlingguy.nginx

# List installed roles
ansible-galaxy list

# Create a new role skeleton
ansible-galaxy init roles/my_new_role

# Install collections
ansible-galaxy collection install community.general

# Install collections from requirements
ansible-galaxy collection install -r requirements.yml
```

```yaml
# requirements.yml
---
roles:
  - name: geerlingguy.nginx
    version: "3.1.0"
  - name: geerlingguy.postgresql
    version: "3.4.0"
  - src: https://github.com/org/ansible-role-app.git
    name: app
    version: v2.0.0

collections:
  - name: community.general
    version: ">=7.0.0"
  - name: amazon.aws
    version: ">=6.0.0"
```

## Linting and Validation

```bash
# Lint a playbook
ansible-lint playbook.yml

# Lint all playbooks and roles in the current directory
ansible-lint

# Lint with strict mode (warnings become errors)
ansible-lint --strict

# Lint with specific profile
ansible-lint -p production

# Syntax check (parse without executing)
ansible-playbook playbook.yml --syntax-check

# YAML lint
yamllint .

# List available lint rules
ansible-lint -L
```

## Molecule Testing

```bash
# Run the full test sequence (create, converge, verify, destroy)
molecule test

# Run tests for a specific scenario
molecule test -s centos

# Create test infrastructure only
molecule create

# Run the playbook against test infrastructure
molecule converge

# Run verification tests
molecule verify

# Log into a test instance
molecule login

# Destroy test infrastructure
molecule destroy

# List test instances
molecule list

# Run idempotency check (converge twice, assert zero changes)
molecule converge && molecule idempotence
```

## Debugging

```bash
# Run with debug task output
ANSIBLE_STDOUT_CALLBACK=debug ansible-playbook playbook.yml

# Enable full module argument logging (CAUTION: exposes secrets)
ANSIBLE_DISPLAY_ARGS_TO_STDOUT=true ansible-playbook playbook.yml

# Profile task execution times
ANSIBLE_CALLBACKS_ENABLED=timer,profile_tasks ansible-playbook playbook.yml

# Generate a detailed log file
ANSIBLE_LOG_PATH=./ansible.log ansible-playbook playbook.yml

# Dump all variables for a host
ansible web01 -m ansible.builtin.debug -a "var=hostvars[inventory_hostname]"

# Check effective configuration
ansible-config dump --changed
```

## CI/CD Pipeline Pattern

```bash
# 1. Lint
ansible-lint --strict
yamllint .

# 2. Syntax check
ansible-playbook site.yml --syntax-check

# 3. Molecule tests (for roles)
cd roles/myapp && molecule test

# 4. Dry-run against staging
ansible-playbook -i inventory/staging site.yml --check --diff

# 5. Deploy to staging
ansible-playbook -i inventory/staging site.yml

# 6. Verify staging
ansible-playbook -i inventory/staging verify.yml

# 7. Deploy to production (manual gate)
ansible-playbook -i inventory/production site.yml --forks=5

# 8. Verify production
ansible-playbook -i inventory/production verify.yml
```
