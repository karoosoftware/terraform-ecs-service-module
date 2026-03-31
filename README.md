# AWS ECS Service Module

This module provides the foundational ECS resources needed for a long-running AWS ECS workload, including an ECS service, task definition, task IAM role, CloudWatch log group, and service security group.

## What This Module Creates

- 1 CloudWatch log group
- 1 ECS service
- 1 ECS task IAM role
- 1 ECS task definition
- 1 ECS service security group

## Usage

```hcl
module "ecs_service" {
  source = "git::ssh://git@github.com:karoosoftware/terraform-ecs-service-module.git?ref=<commit-sha>"

  log_group_name              = "/ecs/margana-api-preprod"
  task_role_name              = "margana-api-task-role-preprod"
  family                      = "margana-api-preprod"
  cpu                         = "256"
  memory                      = "512"
  execution_role_arn          = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
  container_name              = "margana-api-preprod"
  image                       = "123456789012.dkr.ecr.eu-west-2.amazonaws.com/margana-api:latest"
  command                     = []
  container_entry_point       = []
  container_port_mappings = [
    {
      container_port = 8080
      protocol       = "tcp"
    }
  ]
  container_environment = [
    {
      name  = "APP_ENV"
      value = "preprod"
    }
  ]
  container_secrets = [
    {
      name       = "DATABASE_URL"
      value_from = "arn:aws:ssm:eu-west-2:123456789012:parameter/margana/preprod/database-url"
    }
  ]
  container_health_check = {
    command      = ["CMD-SHELL", "curl -f http://localhost:8080/health || exit 1"]
    interval     = 30
    timeout      = 5
    retries      = 3
    start_period = 10
  }
  aws_region                  = "eu-west-2"
  vpc_id                      = "vpc-0123456789abcdef0"
  service_security_group_name = "margana-api-service-sg-preprod"
  service_name                = "margana-api-preprod"
  cluster_arn                 = "arn:aws:ecs:eu-west-2:123456789012:cluster/margana"
  desired_count               = 1
  subnet_ids                  = ["subnet-0123456789abcdef0", "subnet-abcdef0123456789"]
  assign_public_ip            = false
  enable_execute_command      = false
  propagate_tags              = "SERVICE"
  wait_for_steady_state       = true

  tags = {
    Environment = "preprod"
    Application = "Margana"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `log_group_name` | Name of the CloudWatch log group for the ECS task. | `string` | n/a | yes |
| `log_retention_in_days` | Number of days to retain CloudWatch log events. | `number` | `30` | no |
| `task_role_name` | Name of the IAM role assumed by the ECS task. | `string` | n/a | yes |
| `family` | Family name of the ECS task definition. | `string` | n/a | yes |
| `cpu` | CPU units used by the task. | `string` | n/a | yes |
| `memory` | Memory in MiB used by the task. | `string` | n/a | yes |
| `execution_role_arn` | ARN of the ECS task execution role. | `string` | n/a | yes |
| `container_name` | Name of the container in the task definition. | `string` | n/a | yes |
| `image` | Container image URI to run. | `string` | n/a | yes |
| `command` | Optional command to pass to the container. | `list(string)` | `[]` | no |
| `container_entry_point` | Optional entry point for the ECS container. | `list(string)` | `[]` | no |
| `container_port_mappings` | Port mappings for the ECS container. | `list(object({ container_port = number, host_port = optional(number), protocol = optional(string, "tcp") }))` | `[]` | no |
| `container_environment` | Environment variables for the ECS container. | `list(object({ name = string, value = string }))` | `[]` | no |
| `container_secrets` | Secrets to inject into the ECS container. | `list(object({ name = string, value_from = string }))` | `[]` | no |
| `container_health_check` | Health check configuration for the ECS container. | `object({ command = list(string), interval = optional(number, 30), timeout = optional(number, 5), retries = optional(number, 3), start_period = optional(number, 0) })` | `null` | no |
| `aws_region` | AWS region for CloudWatch Logs configuration. | `string` | n/a | yes |
| `vpc_id` | ID of the VPC where the ECS service will run. | `string` | n/a | yes |
| `service_security_group_name` | Name of the security group attached to the ECS service. | `string` | n/a | yes |
| `service_name` | Name of the ECS service. | `string` | n/a | yes |
| `cluster_arn` | ARN of the ECS cluster where the service will run. | `string` | n/a | yes |
| `desired_count` | Number of tasks to run in the ECS service. | `number` | `1` | no |
| `subnet_ids` | Subnet IDs for the ECS service network configuration. | `list(string)` | n/a | yes |
| `assign_public_ip` | Whether to assign a public IP to the service tasks. | `bool` | `false` | no |
| `enable_execute_command` | Whether to enable ECS Exec for the service. | `bool` | `false` | no |
| `propagate_tags` | Whether to propagate tags from the service or task definition. | `string` | `"SERVICE"` | no |
| `wait_for_steady_state` | Whether Terraform should wait for the service to reach a steady state. | `bool` | `true` | no |
| `deployment_minimum_healthy_percent` | Lower limit on the number of running tasks during a deployment, as a percentage of desired count. | `number` | `100` | no |
| `deployment_maximum_percent` | Upper limit on the number of running tasks during a deployment, as a percentage of desired count. | `number` | `200` | no |
| `tags` | Tags to apply to resources created by this module. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `task_role_arn` | ARN of the IAM role assumed by the ECS task |
| `task_role_name` | Name of the IAM role assumed by the ECS task |
| `task_definition_arn` | ARN of the ECS task definition |
| `task_definition_family` | Family name of the ECS task definition |
| `service_security_group_id` | ID of the security group attached to the ECS service |
| `service_security_group_name` | Name of the security group attached to the ECS service |
| `service_arn` | ARN of the ECS service |
| `service_name` | Name of the ECS service |

## Notes

- This module creates the service-scoped resources needed for a long-running ECS workload.
- This module creates an egress-only security group for the ECS service.
- Ingress rules are managed externally by the caller or by separate networking or load balancer modules.
- Use the exported `service_security_group_id` output when attaching ingress rules outside this module.
- `propagate_tags` must be one of `NONE`, `SERVICE`, or `TASK_DEFINITION`.
- `container_port_mappings.protocol` must be either `tcp` or `udp`.
- Shared VPC networking such as VPC endpoints is better managed by a VPC or platform networking module.

## Release Process

- Update the root `VERSION` file in the same change that should be released, using semantic versioning such as `1.0.1`, `1.1.0`, or `2.0.0`.
- Push the change to `develop` and let the `terraform-validate` workflow pass.
- Open a pull request from `develop` to `main` and let the `terraform-validate` workflow pass again.
- Merge the pull request to `main`.
- Pushing to `main` triggers the automated release workflow, which:
  - reads `VERSION`,
  - checks that tag `v<VERSION>` does not already exist,
  - creates and pushes the tag,
  - creates the GitHub release automatically.
- If `VERSION` has not been updated and the tag already exists, validation and release will fail.
- Consume released versions from other Terraform repos by pinning the module source with the released tag, for example:

```bash
source = "git::ssh://git@github.com:karoosoftware/terraform-ecs-service-module.git?ref=v1.0.0"
```

## Prerequisites

- Terraform 1.x
- AWS provider configured in the root module
- IAM permissions to create ECS services, ECS task definitions, IAM roles, CloudWatch log groups, and security groups
