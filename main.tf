locals {
  container_definition = merge(
    {
      name      = var.container_name
      image     = var.image
      essential = true
      command   = var.command

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    length(var.container_entry_point) > 0 ? {
      entryPoint = var.container_entry_point
    } : {},
    length(var.container_port_mappings) > 0 ? {
      portMappings = [
        for pm in var.container_port_mappings : merge(
          {
            containerPort = pm.container_port
          },
          pm.host_port != null ? { hostPort = pm.host_port } : {},
          pm.protocol != null ? { protocol = pm.protocol } : {}
        )
      ]
    } : {},
    length(var.container_environment) > 0 ? {
      environment = var.container_environment
    } : {},
    length(var.container_secrets) > 0 ? {
      secrets = [
        for secret in var.container_secrets : {
          name      = secret.name
          valueFrom = secret.value_from
        }
      ]
    } : {},
    var.container_health_check != null ? {
      healthCheck = {
        command     = var.container_health_check.command
        interval    = var.container_health_check.interval
        timeout     = var.container_health_check.timeout
        retries     = var.container_health_check.retries
        startPeriod = var.container_health_check.start_period
      }
    } : {}
  )
}

resource "aws_ecs_service" "this" {
  name            = var.service_name
  cluster         = var.cluster_arn
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  enable_execute_command = var.enable_execute_command
  propagate_tags         = var.propagate_tags
  wait_for_steady_state  = var.wait_for_steady_state

  deployment_minimum_healthy_percent = var.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.deployment_maximum_percent

  network_configuration {
    subnets          = var.subnet_ids
    security_groups  = [aws_security_group.service.id]
    assign_public_ip = var.assign_public_ip
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "this" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_in_days

  tags = var.tags
}


# Task role name
data "aws_iam_policy_document" "task_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "task" {
  name               = var.task_role_name
  assume_role_policy = data.aws_iam_policy_document.task_assume_role.json

  tags = var.tags
}

# Task definition
resource "aws_ecs_task_definition" "this" {
  family                   = var.family
  cpu                      = var.cpu
  memory                   = var.memory
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = var.execution_role_arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([local.container_definition])

  tags = var.tags
}

# Service security group
resource "aws_security_group" "service" {
  name        = var.service_security_group_name
  description = "Security group for the ECS service."
  vpc_id      = var.vpc_id

  egress {
    description = "Allow all outbound traffic."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
