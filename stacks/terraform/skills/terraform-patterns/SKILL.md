# Terraform Patterns

## State Management
- Use remote state backends (S3, GCS, Azure Blob) — never commit `.tfstate` files
- Enable state locking with DynamoDB or equivalent to prevent concurrent modifications
- Use `terraform_remote_state` data source sparingly — prefer passing outputs via variables
- Use workspaces or directory-based separation for environment isolation (dev/staging/prod)
- Run `terraform plan` before every `apply` — review changes carefully

## Module Design
- Write reusable modules with clear input variables and output values
- Keep modules focused — one resource group per module (e.g., VPC, EKS, RDS)
- Use `variable` blocks with `type`, `description`, and `default` where appropriate
- Use `locals` to compute derived values — keep `resource` blocks clean
- Pin module versions: `source = "git::https://...?ref=v1.0.0"`

## Security
- Never hardcode secrets — use `var` references, SSM Parameter Store, or Vault
- Use `sensitive = true` on variables and outputs that contain secrets
- Enable encryption at rest for all storage resources
- Use IAM roles with least-privilege policies — avoid wildcard `*` permissions

## Code Organization
- Use a consistent directory layout: `main.tf`, `variables.tf`, `outputs.tf`, `providers.tf`
- Group related resources in the same file — split by concern, not by resource type
- Use `terraform fmt` for consistent formatting
- Use `count` or `for_each` for conditional and repeated resources — prefer `for_each`

## Testing
- Use `terraform validate` for syntax and configuration checks
- Use `terraform plan` as a lightweight verification step in CI
- Use `terratest` or `tftest` for integration testing
- Tag all resources with `Environment`, `Team`, and `ManagedBy = "terraform"`
