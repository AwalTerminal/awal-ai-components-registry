# Terraform Patterns

## Module Design and Composition

### Module Structure

Every module follows a standard file layout:

```
modules/vpc/
  main.tf          # Resource definitions
  variables.tf     # Input variables with types, descriptions, defaults
  outputs.tf       # Output values for consumers
  versions.tf      # Required providers and Terraform version constraints
  locals.tf        # Computed values and intermediate expressions
  data.tf          # Data sources (optional, for lookup-heavy modules)
  README.md        # Usage examples and variable reference
```

### Input Variable Design

Define clear contracts with validation:

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type for the application servers"
  default     = "t3.micro"

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Only t3 instance types are allowed."
  }
}

variable "tags" {
  type        = map(string)
  description = "Additional tags to apply to all resources"
  default     = {}
}
```

### Module Composition

Compose infrastructure from focused, single-purpose modules:

```hcl
module "vpc" {
  source  = "./modules/vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["us-east-1a", "us-east-1b", "us-east-1c"]
  environment = var.environment
}

module "database" {
  source          = "./modules/rds"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  instance_class  = var.db_instance_class
  environment     = var.environment
}

module "application" {
  source          = "./modules/ecs-service"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnet_ids
  lb_target_group = module.load_balancer.target_group_arn
  db_endpoint     = module.database.endpoint
  environment     = var.environment
}
```

### Module Versioning

Pin module sources for reproducibility:

```hcl
# Git-based modules — pin to tags, never branches
module "vpc" {
  source = "git::https://github.com/org/terraform-modules.git//vpc?ref=v2.1.0"
}

# Terraform registry modules — use version constraints
module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 3.15"
}

# Local modules — use relative paths
module "iam_role" {
  source = "../../modules/iam-role"
}
```

## State Management

### Remote Backend Configuration

```hcl
terraform {
  backend "s3" {
    bucket         = "myorg-terraform-state"
    key            = "services/api/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

### State Key Hierarchy

Organize state files with a consistent key structure:

```
terraform-state/
  network/vpc/terraform.tfstate
  network/dns/terraform.tfstate
  services/api/terraform.tfstate
  services/worker/terraform.tfstate
  data/rds-primary/terraform.tfstate
  platform/eks/terraform.tfstate
```

### Environment Isolation: Directories vs Workspaces

**Directory-based (preferred for distinct configurations):**

```
environments/
  dev/
    main.tf          # Calls shared modules with dev-specific values
    terraform.tfvars
    backend.tf       # Separate state file per environment
  staging/
    main.tf
    terraform.tfvars
    backend.tf
  prod/
    main.tf
    terraform.tfvars
    backend.tf
```

**Workspace-based (when configurations are identical, only values differ):**

```hcl
locals {
  env_config = {
    dev     = { instance_type = "t3.micro",  min_size = 1 }
    staging = { instance_type = "t3.small",  min_size = 2 }
    prod    = { instance_type = "t3.medium", min_size = 3 }
  }
  config = local.env_config[terraform.workspace]
}
```

Use directory-based isolation for production. Workspaces share provider configuration and backend, which becomes a liability when environments diverge.

## Resource Patterns

### Naming and Tagging

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "terraform"
    Team        = var.team
  }
}

resource "aws_instance" "app" {
  ami           = data.aws_ami.app.id
  instance_type = var.instance_type
  tags          = merge(local.common_tags, { Name = "${local.name_prefix}-app" })
}
```

### for_each Over count

Use `for_each` for resources that need stable identity — prevents index-shift destruction:

```hcl
# GOOD: stable keys, removing "b" does not affect "a" or "c"
variable "subnets" {
  default = {
    a = { cidr = "10.0.1.0/24", az = "us-east-1a" }
    b = { cidr = "10.0.2.0/24", az = "us-east-1b" }
    c = { cidr = "10.0.3.0/24", az = "us-east-1c" }
  }
}

resource "aws_subnet" "this" {
  for_each          = var.subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags              = { Name = "${local.name_prefix}-${each.key}" }
}

# BAD: index-based, removing item at index 0 forces recreation of all subsequent
resource "aws_subnet" "this" {
  count             = length(var.subnet_cidrs)
  cidr_block        = var.subnet_cidrs[count.index]
}
```

Reserve `count` only for conditional creation:

```hcl
resource "aws_cloudwatch_log_group" "this" {
  count = var.enable_logging ? 1 : 0
  name  = "/app/${var.service_name}"
}
```

### Dynamic Blocks vs Separate Resources

Prefer separate resources for independently managed lifecycle:

```hcl
# GOOD: security group rules as separate resources
resource "aws_security_group" "app" {
  name   = "${local.name_prefix}-app"
  vpc_id = aws_vpc.main.id
}

resource "aws_security_group_rule" "app_ingress_http" {
  security_group_id = aws_security_group.app.id
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

# Use dynamic blocks only for tightly coupled, non-independently-managed sub-blocks
resource "aws_autoscaling_group" "app" {
  dynamic "tag" {
    for_each = local.common_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
```

## Anti-Patterns

### Data Source Abuse
Avoid using data sources to look up resources managed in the same configuration. Pass values directly through module outputs or variable references. Data sources introduce implicit dependencies and timing issues.

### Inline Provider Configuration
Never put provider blocks inside modules. Providers are configured at the root level and passed to modules via the `providers` meta-argument.

### Overly Large Root Modules
If a root module exceeds 500 lines of HCL, split it into composable child modules. A root module should primarily compose modules and wire outputs to inputs.

### Hardcoded Resource References
Never hardcode ARNs, account IDs, or region names. Use data sources (`aws_caller_identity`, `aws_region`) or variables.

## Testing

### Plan Review Checklist
Before approving any `terraform plan`:
1. Verify no resources marked for destruction unless intended
2. Check that `forces replacement` actions are expected
3. Confirm sensitive values are not exposed in plan output
4. Verify the count of resources to add/change/destroy is reasonable
5. Look for unexpected changes caused by provider upgrades

### Automated Testing with Terratest

```go
func TestVpcModule(t *testing.T) {
    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../modules/vpc",
        Vars: map[string]interface{}{
            "cidr":        "10.0.0.0/16",
            "environment": "test",
        },
    })
    defer terraform.Destroy(t, terraformOptions)
    terraform.InitAndApply(t, terraformOptions)

    vpcId := terraform.Output(t, terraformOptions, "vpc_id")
    assert.Regexp(t, `^vpc-`, vpcId)
}
```

### Native Terraform Tests (1.6+)

```hcl
# tests/vpc.tftest.hcl
run "creates_vpc" {
  command = plan

  variables {
    cidr        = "10.0.0.0/16"
    environment = "test"
  }

  assert {
    condition     = aws_vpc.main.cidr_block == "10.0.0.0/16"
    error_message = "VPC CIDR block does not match"
  }
}
```

## Drift Detection

Run `terraform plan` on a schedule in CI to detect out-of-band changes. Alert on any non-empty plan output. Use `terraform refresh` cautiously — it updates state to match real infrastructure but can mask intentional state divergences.

```bash
# CI drift detection job
terraform plan -detailed-exitcode -out=drift.tfplan
# Exit code 0 = no changes, 1 = error, 2 = changes detected
if [ $? -eq 2 ]; then
  notify_team "Terraform drift detected in $(basename $PWD)"
fi
```
