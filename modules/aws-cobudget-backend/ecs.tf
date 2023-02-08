resource "aws_ecs_cluster" "cobudget" {
  name = var.cluster_name
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

data "aws_iam_policy_document" "ecs_cobudget_get_ssm" {
  statement {
    actions = ["ssm:GetParameters"]
    resources = [
      aws_ssm_parameter.cobudget_jdbc_database_url.arn,
      aws_ssm_parameter.cobudget_jdbc_database_username.arn,
      aws_ssm_parameter.cobudget_jdbc_database_password.arn,
    ]
  }
}

resource "aws_iam_policy" "ecs_cobudget_get_ssm" {
  name        = "ecs-cobudget-get-ssm"
  description = "Policy to get parameters from SSM"
  policy      = data.aws_iam_policy_document.ecs_cobudget_get_ssm.json
}

resource "aws_iam_role_policy_attachment" "ecs_cobudget_get_ssm" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ecs_cobudget_get_ssm.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}