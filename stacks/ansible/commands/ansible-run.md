# Ansible Run & Test

Run with ansible CLI:
- `ansible-playbook playbook.yml` — run a playbook
- `ansible-playbook playbook.yml --check --diff` — dry-run with diff output
- `ansible-playbook playbook.yml -l staging` — limit to a host group
- `ansible-playbook playbook.yml -t deploy` — run only tagged tasks
- `ansible-lint playbook.yml` — lint a playbook
- `ansible-vault encrypt secrets.yml` — encrypt a secrets file
- `ansible-inventory --graph` — show inventory structure
- `ansible all -m ping` — test connectivity to all hosts
