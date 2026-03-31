variable "log_group_name" {
  description = "Name of the CloudWatch log group for the ECS task."
  type        = string
}

variable "log_retention_in_days" {
  description = "Number of days to retain CloudWatch log events."
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources created by this module."
  type        = map(string)
  default     = {}
}

variable "task_role_name" {
  description = "Name of the IAM role assumed by the ECS task."
  type        = string
}

variable "family" {
  description = "Family name of the ECS task definition."
  type        = string
}

variable "cpu" {
  description = "CPU units used by the task."
  type        = string
}

variable "memory" {
  description = "Memory in MiB used by the task."
  type        = string
}

variable "execution_role_arn" {
  description = "ARN of the ECS task execution role."
  type        = string
}

variable "container_name" {
  description = "Name of the container in the task definition."
  type        = string
}

variable "image" {
  description = "Container image URI to run."
  type        = string
}

variable "command" {
  description = "Optional command to pass to the container."
  type        = list(string)
  default     = []
}

variable "aws_region" {
  description = "AWS region for CloudWatch Logs configuration."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the ECS service will run."
  type        = string
}

variable "service_security_group_name" {
  description = "Name of the security group attached to the ECS service."
  type        = string
}

variable "service_name" {
  description = "Name of the ECS service."
  type        = string
}

variable "cluster_arn" {
  description = "ARN of the ECS cluster where the service will run."
  type        = string
}

variable "desired_count" {
  description = "Number of tasks to run in the ECS service."
  type        = number
  default     = 1
}

variable "subnet_ids" {
  description = "Subnet IDs for the ECS service network configuration."
  type        = list(string)
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP to the service tasks."
  type        = bool
  default     = false
}

variable "enable_execute_command" {
  description = "Whether to enable ECS Exec for the service."
  type        = bool
  default     = false
}


variable "propagate_tags" {
  description = "Whether to propagate tags from the service or task definition."
  type        = string
  default     = "SERVICE"

  validation {
    condition     = contains(["NONE", "SERVICE", "TASK_DEFINITION"], var.propagate_tags)
    error_message = "propagate_tags must be one of: NONE, SERVICE, TASK_DEFINITION."
  }
}

variable "wait_for_steady_state" {
  description = "Whether Terraform should wait for the service to reach a steady state."
  type        = bool
  default     = true
}

variable "deployment_minimum_healthy_percent" {
  description = "Lower limit on the number of running tasks during a deployment, as a percentage of desired count."
  type        = number
  default     = 100
}

variable "deployment_maximum_percent" {
  description = "Upper limit on the number of running tasks during a deployment, as a percentage of desired count."
  type        = number
  default     = 200
}

variable "container_entry_point" {
  description = "Optional entry point for the ECS container."
  type        = list(string)
  default     = []
}

variable "container_port_mappings" {
  description = "Port mappings for the ECS container."
  type = list(object({
    container_port = number
    host_port      = optional(number)
    protocol       = optional(string, "tcp")
  }))
  default = []

  validation {
    condition = alltrue([
      for mapping in var.container_port_mappings :
      contains(["tcp", "udp"], lower(mapping.protocol))
    ])
    error_message = "Each container_port_mappings.protocol must be either tcp or udp."
  }
}

variable "container_environment" {
  description = "Environment variables for the ECS container."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "container_secrets" {
  description = "Secrets to inject into the ECS container."
  type = list(object({
    name       = string
    value_from = string
  }))
  default = []
}

variable "container_health_check" {
  description = "Health check configuration for the ECS container."
  type = object({
    command      = list(string)
    interval     = optional(number, 30)
    timeout      = optional(number, 5)
    retries      = optional(number, 3)
    start_period = optional(number, 0)
  })
  default = null
}
