resource "aws_ecs_cluster" "cobudget" {
  name = "my-cluster"
}

data "aws_iam_policy_document" "ecs_task_execution_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution" {
  name               = "ecs-task-execution"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    actions   = ["ssm:GetParameters"]
    resources = [
      aws_ssm_parameter.cobudget_jdbc_database_url.arn,
      aws_ssm_parameter.cobudget_jdbc_database_username.arn,
      aws_ssm_parameter.cobudget_jdbc_database_password.arn,
    ]
  }
}

resource "aws_iam_policy" "ecs_task_execution" {
  name_prefix = "ecs-task-execution"
  description = "Policy to get parameters from SSM"
  policy      = data.aws_iam_policy_document.ecs_task_execution.json
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_task_execution.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution2" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.ecs_task_execution.name
}

resource "aws_ecs_task_definition" "cobudget" {
  execution_role_arn    = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      essential    = true
      memory       = 800
      name         = "cobudget"
      image        = "${aws_ecr_repository.ecr_cobudget.repository_url}:latest"
      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]
      environment = [
        {
          name  = "APP_PORT"
          value = "8080"
        },
        {
          name  = "CORS_ORIGINS"
          value = var.frontend_url
        },
        {
          name  = "OAUTH_ISSUER"
          value = var.oauth_issuer
        },
      ]
      secrets = [
        {
          name      = "JDBC_DATABASE_URL"
          valueFrom = aws_ssm_parameter.cobudget_jdbc_database_url.arn
        },
        {
          name      = "JDBC_DATABASE_USERNAME"
          valueFrom = aws_ssm_parameter.cobudget_jdbc_database_username.arn
        },
        {
          name      = "JDBC_DATABASE_PASSWORD"
          valueFrom = aws_ssm_parameter.cobudget_jdbc_database_password.arn
        },
      ]
    }
  ])
  family = "cobudget"
}

resource "aws_ecs_service" "cobudget" {
  name                               = "cobudget"
  cluster                            = aws_ecs_cluster.cobudget.id
  task_definition                    = aws_ecs_task_definition.cobudget.arn
  desired_count                      = 1
  deployment_minimum_healthy_percent = 0
  lifecycle {
    ignore_changes = [desired_count]
  }
}