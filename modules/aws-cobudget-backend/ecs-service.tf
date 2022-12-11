resource "aws_ecs_task_definition" "cobudget" {
  execution_role_arn    = aws_iam_role.ecs_task_execution.arn
  container_definitions = jsonencode([
    {
      essential    = true
      memory       = 400
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

resource "local_file" "cobudget_deploy" {
  filename = "scripts/deploy-${var.env}.sh"
  content  = <<EOF
#!/usr/bin/env bash
aws ecs update-service --cluster ${aws_ecs_cluster.cobudget.name} --service ${aws_ecs_service.cobudget.name} --force-new-deployment
  EOF
}
