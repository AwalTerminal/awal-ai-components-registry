# Terraform Style Rules

- Run `terraform fmt` before committing — enforce in CI with `terraform fmt -check`
- Use `snake_case` for all resource names, variables, and outputs
- Add `description` to every `variable` and `output` block
- Use `for_each` over `count` for resources that need stable identifiers
- Pin provider versions in `required_providers` — never use unconstrained versions
- Keep `.tfvars` files out of version control — use `.tfvars.example` as a template
- Never hardcode secrets or credentials in `.tf` files
- Run `terraform validate` and `tflint` before every plan
