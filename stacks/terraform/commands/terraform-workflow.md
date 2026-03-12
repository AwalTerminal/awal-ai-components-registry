# Terraform Workflow

Run with terraform CLI:
- `terraform init` — initialize providers and modules
- `terraform validate` — check configuration syntax
- `terraform plan` — preview changes
- `terraform apply` — apply changes (with confirmation)
- `terraform plan -out=plan.tfplan && terraform apply plan.tfplan` — safe apply from saved plan
- `terraform fmt -recursive` — format all `.tf` files
- `tflint` — run the Terraform linter
- `terraform state list` — list all resources in state
