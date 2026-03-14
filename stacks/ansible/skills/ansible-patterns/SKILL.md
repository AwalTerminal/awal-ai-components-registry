# Ansible Patterns

## Role Design

### Standard Role Structure

```
roles/nginx/
  tasks/
    main.yml         # Task entry point — includes sub-task files
    install.yml      # Package installation
    configure.yml    # Configuration file management
    service.yml      # Service state management
  handlers/
    main.yml         # Handler definitions (service restarts, reloads)
  templates/
    nginx.conf.j2    # Jinja2 templates
    vhost.conf.j2
  files/
    ssl-params.conf  # Static files to copy
  defaults/
    main.yml         # Default variable values (overridable)
  vars/
    main.yml         # Internal constants (not meant to be overridden)
  meta/
    main.yml         # Role metadata, dependencies, supported platforms
  molecule/
    default/
      molecule.yml   # Test configuration
      converge.yml   # Test playbook
      verify.yml     # Assertions
```

### Task Decomposition

Split `tasks/main.yml` into focused sub-files:

```yaml
# tasks/main.yml
---
- name: Install nginx packages
  ansible.builtin.include_tasks: install.yml
  tags: [nginx, install]

- name: Configure nginx
  ansible.builtin.include_tasks: configure.yml
  tags: [nginx, configure]

- name: Manage nginx service
  ansible.builtin.include_tasks: service.yml
  tags: [nginx, service]
```

```yaml
# tasks/install.yml
---
- name: Install nginx
  ansible.builtin.apt:
    name: "nginx={{ nginx_version }}"
    state: present
    update_cache: true
    cache_valid_time: 3600
  notify: Restart nginx

- name: Install nginx extras
  ansible.builtin.apt:
    name: "{{ nginx_extra_packages }}"
    state: present
  when: nginx_extra_packages | length > 0
```

### Handler Design

```yaml
# handlers/main.yml
---
- name: Restart nginx
  ansible.builtin.systemd:
    name: nginx
    state: restarted
    daemon_reload: true
  listen: "restart nginx"

- name: Reload nginx
  ansible.builtin.systemd:
    name: nginx
    state: reloaded
  listen: "reload nginx"

- name: Validate nginx config
  ansible.builtin.command: nginx -t
  changed_when: false
  listen: "restart nginx"
```

Use `listen` to chain handlers — `Validate nginx config` runs before `Restart nginx` when both listen to the same trigger topic.

### Variable Namespacing

Prefix all role variables with the role name to prevent collisions:

```yaml
# defaults/main.yml
---
nginx_version: "1.24.*"
nginx_worker_processes: auto
nginx_worker_connections: 1024
nginx_keepalive_timeout: 65
nginx_server_names_hash_bucket_size: 64
nginx_extra_packages: []
nginx_vhosts: []
nginx_ssl_enabled: false
nginx_ssl_certificate: ""
nginx_ssl_certificate_key: ""
```

## Variable Precedence

Ansible has 22 levels of variable precedence. The most important ones, from lowest to highest:

1. Role defaults (`defaults/main.yml`) — lowest, meant to be overridden
2. Inventory group vars (`group_vars/`)
3. Inventory host vars (`host_vars/`)
4. Play vars (`vars:` in playbook)
5. Role vars (`vars/main.yml`) — high, for role internals
6. Block vars
7. Task vars
8. Extra vars (`-e` on command line) — highest, always wins

### Practical Layout

```
inventory/
  production/
    hosts.yml
    group_vars/
      all/
        common.yml        # Shared across all hosts
        vault.yml          # Encrypted secrets
      webservers/
        main.yml           # Group-specific vars
      databases/
        main.yml
    host_vars/
      db-primary/
        main.yml           # Host-specific overrides
```

```yaml
# inventory/production/group_vars/all/common.yml
---
ntp_servers:
  - 0.pool.ntp.org
  - 1.pool.ntp.org
timezone: UTC
admin_email: ops@example.com
```

## Vault Usage

### Encrypting Secrets

```yaml
# inventory/production/group_vars/all/vault.yml
---
vault_db_password: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  616263...

vault_api_key: !vault |
  $ANSIBLE_VAULT;1.1;AES256
  646566...
```

### Referencing Vault Variables

Use a naming convention — prefix encrypted values with `vault_`, then reference them through plain variables:

```yaml
# group_vars/all/common.yml
db_password: "{{ vault_db_password }}"
api_key: "{{ vault_api_key }}"
```

This pattern lets you `grep` for all secrets by searching for `vault_` and keeps the indirection clear.

### Vault ID for Multiple Passwords

```bash
# Encrypt with a vault ID
ansible-vault encrypt --vault-id prod@prompt secrets.yml

# Use multiple vault IDs in one run
ansible-playbook site.yml \
  --vault-id dev@dev-vault-pass.txt \
  --vault-id prod@prod-vault-pass.txt
```

## Idempotency Patterns

### Module-Based Idempotency

```yaml
# GOOD: Module handles idempotency
- name: Ensure application user exists
  ansible.builtin.user:
    name: appuser
    system: true
    shell: /sbin/nologin
    home: /opt/app
    create_home: true

# GOOD: Template only changes file when content differs
- name: Deploy application config
  ansible.builtin.template:
    src: app.conf.j2
    dest: /etc/app/config.yml
    owner: appuser
    mode: "0640"
    validate: "/opt/app/bin/app validate-config %s"
  notify: Restart application
```

### Shell/Command Idempotency

When a module does not exist, use `creates`, `removes`, or `when` conditions:

```yaml
# GOOD: Skip if output file already exists
- name: Build application from source
  ansible.builtin.command:
    cmd: make build
    chdir: /opt/app/src
    creates: /opt/app/bin/app

# GOOD: Conditional execution based on check
- name: Initialize database
  ansible.builtin.command:
    cmd: /opt/app/bin/app db init
  register: db_check
  changed_when: "'initialized' in db_check.stdout"
  when: db_initialized_flag.stat.exists is false
```

### Verification Pattern

```yaml
- name: Verify service is running after deploy
  ansible.builtin.uri:
    url: "http://{{ inventory_hostname }}:8080/health"
    status_code: 200
  register: health_check
  retries: 10
  delay: 5
  until: health_check.status == 200
```

## Dynamic Inventory

### AWS EC2 Plugin

```yaml
# inventory/aws_ec2.yml
---
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1
keyed_groups:
  - key: tags.Environment
    prefix: env
    separator: "_"
  - key: tags.Role
    prefix: role
    separator: "_"
  - key: placement.availability_zone
    prefix: az
filters:
  tag:ManagedBy: ansible
  instance-state-name: running
compose:
  ansible_host: private_ip_address
```

### Dynamic Group Usage

```yaml
# After dynamic inventory groups hosts as: env_production, role_webserver, az_us_east_1a
- hosts: env_production:&role_webserver
  roles:
    - nginx
    - app-deploy
```

## Block Error Handling

```yaml
- name: Deploy application with rollback
  block:
    - name: Stop application
      ansible.builtin.systemd:
        name: myapp
        state: stopped

    - name: Deploy new version
      ansible.builtin.copy:
        src: "myapp-{{ app_version }}"
        dest: /opt/app/bin/myapp
        mode: "0755"

    - name: Start application
      ansible.builtin.systemd:
        name: myapp
        state: started

    - name: Verify health
      ansible.builtin.uri:
        url: "http://localhost:8080/health"
        status_code: 200
      retries: 5
      delay: 3

  rescue:
    - name: Rollback to previous version
      ansible.builtin.copy:
        src: "myapp-{{ app_previous_version }}"
        dest: /opt/app/bin/myapp
        mode: "0755"

    - name: Start previous version
      ansible.builtin.systemd:
        name: myapp
        state: started

    - name: Notify failure
      ansible.builtin.debug:
        msg: "Deployment of {{ app_version }} failed. Rolled back to {{ app_previous_version }}."

  always:
    - name: Ensure service is running
      ansible.builtin.systemd:
        name: myapp
        state: started
```

## Molecule Testing

### Test Configuration

```yaml
# molecule/default/molecule.yml
---
dependency:
  name: galaxy
driver:
  name: docker
platforms:
  - name: ubuntu-test
    image: ubuntu:22.04
    pre_build_image: true
    tmpfs:
      - /run
      - /tmp
provisioner:
  name: ansible
  playbooks:
    converge: converge.yml
    verify: verify.yml
verifier:
  name: ansible
```

```yaml
# molecule/default/converge.yml
---
- name: Converge
  hosts: all
  become: true
  roles:
    - role: nginx
      nginx_vhosts:
        - server_name: test.local
          root: /var/www/test
```

```yaml
# molecule/default/verify.yml
---
- name: Verify
  hosts: all
  tasks:
    - name: Check nginx is running
      ansible.builtin.systemd:
        name: nginx
      register: nginx_service
      failed_when: nginx_service.status.ActiveState != "active"

    - name: Check nginx is listening on port 80
      ansible.builtin.wait_for:
        port: 80
        timeout: 5
```

## Anti-Patterns

### Shell/Command Overuse
If a module exists for the task, use it. `shell` and `command` hide what the task does, bypass idempotency checks, and create platform-specific coupling.

### ignore_errors
Using `ignore_errors: true` masks real failures. Use `failed_when` with specific conditions, or `block/rescue` for error handling.

### Unvaulted Secrets
Never commit plaintext credentials. Encrypt all secret files with `ansible-vault`. Use `no_log: true` on tasks that handle secret values to prevent them from appearing in output.

### Monolithic Playbooks
Playbooks exceeding 100 lines should be decomposed into roles. Each role should handle a single concern.

### Hardcoded Hosts
Never hardcode IP addresses or hostnames in playbooks. Use inventory groups and variables.
