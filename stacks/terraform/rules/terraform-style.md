# Terraform Style and Security Rules

## Naming Conventions

- Use `snake_case` for all resource names, variables, outputs, locals, and data sources
- Prefix resource names with the service or domain: `aws_security_group.api_ingress`, not `aws_security_group.sg1`
- Use the name `this` for resources when a module manages a single primary resource of that type
- Name outputs without the resource type: `id` not `vpc_id` (the module name already provides context)
- Use `locals` for computed names to ensure consistency across resources

## File Organization

- `main.tf` — Primary resource definitions
- `variables.tf` — All input variable declarations (alphabetically ordered)
- `outputs.tf` — All output declarations
- `versions.tf` — `terraform` block with `required_version` and `required_providers`
- `providers.tf` — Provider configuration (root module only)
- `locals.tf` — Local value definitions
- `data.tf` — Data source declarations
- `backend.tf` — Backend configuration (root module only)
- Never put provider blocks inside child modules

## Formatting and Linting

- Run `terraform fmt -recursive` before every commit
- Enforce `terraform fmt -check` in CI — fail the pipeline on unformatted code
- Run `terraform validate` after every change
- Run `tflint` with the AWS/Azure/GCP ruleset enabled
- Use `tfsec` or `checkov` for static security analysis in CI
- Enable pre-commit hooks: `terraform fmt`, `terraform validate`, `tflint`, `tfsec`

## Variable Discipline

- Every `variable` block must include `type` and `description`
- Set `default` only when a sensible default exists — force explicit values for environment-specific inputs
- Use `sensitive = true` for any variable containing secrets, tokens, passwords, or API keys
- Mark outputs as `sensitive = true` when they expose secret values
- Never set defaults for secrets — always require explicit injection
- Use validation blocks to enforce value constraints at plan time
- Keep `.tfvars` files out of version control — commit `.tfvars.example` with placeholder values

## Provider Management

- Pin provider versions with pessimistic constraints: `~> 5.0` (allows 5.x, prevents 6.0)
- Pin the Terraform version: `required_version = "~> 1.7"`
- Commit the `.terraform.lock.hcl` file — it ensures reproducible provider installations
- Run `terraform init -upgrade` deliberately, not habitually — review provider changelogs first
- Use provider aliases for multi-region or multi-account deployments

## Security Rules

- **No hardcoded secrets:** Never put credentials, tokens, or private keys in `.tf` or `.tfvars` files
- **State encryption:** Enable server-side encryption on the state backend (S3 `encrypt = true`, GCS default encryption)
- **State access control:** Restrict state bucket access to the CI/CD service account and senior operators
- **Least-privilege IAM:** Define IAM policies with specific resource ARNs and actions — never use `"*"` for both
- **Sensitive outputs:** Mark any output containing secrets with `sensitive = true`
- **No inline credentials in providers:** Use environment variables, instance profiles, or workload identity
- **Rotate state encryption keys** on a schedule — re-encrypt state after rotation
- **Enable DynamoDB state locking** to prevent concurrent writes that corrupt state
- **Audit state access:** Enable access logging on the state bucket

## Resource Rules

- Use `for_each` over `count` for resources that need stable identity across changes
- Prefer separate resources over inline blocks for independently managed configuration
- Tag every resource with `Environment`, `Team`, `Project`, and `ManagedBy = "terraform"`
- Set `prevent_destroy = true` lifecycle rule on stateful resources (databases, S3 buckets with data)
- Use `create_before_destroy = true` for resources that cannot tolerate downtime during replacement
- Use `ignore_changes` sparingly and document why — it hides drift

## Module Rules

- Modules must not contain `provider` blocks — accept providers from the caller
- Pin remote module versions — never use unversioned `source` references
- Limit module depth to two levels (root calls child, child does not call grandchild modules)
- Every module must have at least one output — otherwise it is a dead end
- Document module usage with a README including a minimal example

## State Operations Safety

- Never run `terraform state rm` or `terraform state mv` without a state backup
- Always run `terraform plan` after any state manipulation to verify consistency
- Use `terraform import` to bring existing resources under management — never recreate them
- Avoid `terraform taint` — use `terraform apply -replace=RESOURCE` instead (explicit, plannable)
