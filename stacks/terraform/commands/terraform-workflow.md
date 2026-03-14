# Terraform Workflow Commands

## Initialization

```bash
# Initialize providers and modules — run after cloning or adding new providers
terraform init

# Re-initialize after backend configuration changes
terraform init -reconfigure

# Upgrade providers to latest versions within constraints
terraform init -upgrade

# Initialize with a specific backend config (useful for CI)
terraform init -backend-config="bucket=myorg-state" -backend-config="key=services/api/terraform.tfstate"
```

## Validation and Linting

```bash
# Validate configuration syntax and internal consistency
terraform validate

# Format all .tf files recursively
terraform fmt -recursive

# Check formatting without modifying (CI gate)
terraform fmt -check -recursive

# Lint with tflint (install plugin for your cloud provider)
tflint --init
tflint --recursive

# Static security analysis
tfsec .
checkov -d .
```

## Planning

```bash
# Preview changes
terraform plan

# Save plan to file for deterministic apply
terraform plan -out=tfplan

# Plan targeting a specific resource (use sparingly)
terraform plan -target=module.vpc

# Plan with variable overrides
terraform plan -var="environment=staging" -var="instance_type=t3.large"

# Plan with a variable file
terraform plan -var-file="environments/prod.tfvars"

# Detailed exit codes for CI (0=no changes, 1=error, 2=changes pending)
terraform plan -detailed-exitcode -out=tfplan
```

## Applying

```bash
# Apply from a saved plan (preferred — guarantees what was reviewed is what gets applied)
terraform plan -out=tfplan && terraform apply tfplan

# Apply with auto-approve (CI pipelines only, after plan review)
terraform apply -auto-approve tfplan

# Apply targeting a specific resource (emergency only)
terraform apply -target=aws_instance.app

# Replace a specific resource (replaces deprecated taint)
terraform apply -replace=aws_instance.app
```

## Destroying

```bash
# Preview destruction
terraform plan -destroy

# Destroy all resources (requires confirmation)
terraform destroy

# Destroy a specific resource
terraform destroy -target=aws_instance.app

# Destroy with auto-approve (CI teardown jobs)
terraform destroy -auto-approve
```

## State Operations

```bash
# List all resources in state
terraform state list

# Show details of a specific resource in state
terraform state show aws_instance.app

# Pull full state to stdout (for inspection)
terraform state pull

# Move a resource to a new address (refactoring)
terraform state mv aws_instance.old aws_instance.new

# Move a resource into a module
terraform state mv aws_instance.app module.app.aws_instance.this

# Remove a resource from state (without destroying it)
terraform state rm aws_instance.legacy

# Import an existing resource into state
terraform import aws_instance.app i-1234567890abcdef0

# Import into a module resource
terraform import module.vpc.aws_vpc.this vpc-abcdef123

# Force unlock state (when lock is stuck — use with extreme caution)
terraform force-unlock LOCK_ID
```

## Workspace Operations

```bash
# List workspaces
terraform workspace list

# Create and switch to a new workspace
terraform workspace new staging

# Switch to an existing workspace
terraform workspace select prod

# Show current workspace
terraform workspace show

# Delete a workspace (must switch away first)
terraform workspace delete staging
```

## Output and Debugging

```bash
# Show all outputs
terraform output

# Show a specific output in raw format
terraform output -raw database_endpoint

# Show output as JSON (useful for scripting)
terraform output -json

# Generate a dependency graph (pipe to Graphviz)
terraform graph | dot -Tpng > graph.png

# Enable verbose logging
TF_LOG=DEBUG terraform plan

# Log to file
TF_LOG=TRACE TF_LOG_PATH=terraform.log terraform plan
```

## CI/CD Pipeline Pattern

```bash
# 1. Initialize
terraform init -input=false

# 2. Validate
terraform validate
terraform fmt -check

# 3. Plan and save
terraform plan -input=false -out=tfplan -detailed-exitcode
PLAN_EXIT=$?

# 4. On PR: post plan output as comment, require approval
# On merge to main: apply the saved plan
if [ "$PLAN_EXIT" -eq 2 ]; then
  terraform apply -input=false -auto-approve tfplan
fi

# 5. Drift detection (scheduled)
terraform plan -input=false -detailed-exitcode
if [ $? -eq 2 ]; then
  echo "DRIFT DETECTED" && notify_team
fi
```

## Vault and Secrets Integration

```bash
# Pass secrets via environment variables (preferred in CI)
export TF_VAR_db_password="$(vault kv get -field=password secret/db)"
terraform apply

# Pass secrets via -var flag (avoid — visible in process list)
terraform apply -var="db_password=secret"
```

## Cleanup

```bash
# Remove local terraform cache (re-run init after)
rm -rf .terraform/

# Remove cached plan files
rm -f *.tfplan

# Clean up old workspaces
terraform workspace select default
terraform workspace delete old-feature-branch
```
