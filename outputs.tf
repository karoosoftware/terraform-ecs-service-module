output "task_role_arn" {
  description = "ARN of the IAM role assumed by the ECS task."
  value       = aws_iam_role.task.arn
}

output "task_role_name" {
  description = "Name of the IAM role assumed by the ECS task."
  value       = aws_iam_role.task.name
}

output "task_definition_arn" {
  description = "ARN of the ECS task definition."
  value       = aws_ecs_task_definition.this.arn
}

output "task_definition_family" {
  description = "Family name of the ECS task definition."
  value       = aws_ecs_task_definition.this.family
}

output "service_security_group_id" {
  description = "ID of the security group attached to the ECS service."
  value       = aws_security_group.service.id
}

output "service_security_group_name" {
  description = "Name of the security group attached to the ECS service."
  value       = aws_security_group.service.name
}

output "service_arn" {
  description = "ARN of the ECS service."
  value       = aws_ecs_service.this.id
}

output "service_name" {
  description = "Name of the ECS service."
  value       = aws_ecs_service.this.name
}
