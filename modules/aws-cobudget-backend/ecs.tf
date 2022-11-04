resource "aws_security_group" "cobudget_ecs" {
  vpc_id = aws_vpc.cobudget.id
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "ecs_agent" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_agent" {
  name               = "ecs-agent"
  assume_role_policy = data.aws_iam_policy_document.ecs_agent.json
}

resource "aws_iam_role_policy_attachment" "ecs_agent" {
  role       = aws_iam_role.ecs_agent.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.ecs_agent.name
}

data "aws_ami" "cobudget" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
}

resource "aws_key_pair" "cobudget" {
  key_name   = "cobudget"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDV9brHJCm7kD7yJ56DEjhU7sckMLa/wj3tWGuyhHjma0grspV6fyAgPaBzZq1RX0sujlgdIBR4b1i9fIUrcp4OcdZLaxdupJbUvew8BqwWgJnmjuwSvhrrHPdweJK5LIE82SYakM0ptBWpRzaRLGoz9P71ElVRIPtVYDAbHSrHrxy7jX5H+7ExTkKcUDYeGXaeAlzxNM6qDaoPI9APX2MbR/L6HzrwbfiUb6U8jLqJOYghCwwl8A6DjaTBBGqDMDcT5yjMF0Y39hNTfrYzxQ6V6Uq6+WEHLnE+WLUlblvwJtMhfsQvmFQybROsGY5clUa+6pW7V7TAHL8RuG7LufmpvgQK0ci2ummeIYGk6IZQHAl+9HFgnHDqe/ZpTFewnfeb2kpZIweogWpzouAjIuWmRXn2kuKggy1p45BbPnXOhyFGZlkJhoHO0iqrbWL5N8RWZ1JjviJrQo2QN5Iqo6q7hzbeCxAH2Ksvn+bgnZCGtBfjXejfOk+vKXxlBHMJh58= dawids@dawid-ms7d43"
}

resource "aws_instance" "cobudget" {
  ami                         = data.aws_ami.cobudget.id
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.name
  vpc_security_group_ids      = [aws_security_group.cobudget_ecs.id]
  instance_type               = "t2.micro"
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.cobudget_public.id
  key_name                    = aws_key_pair.cobudget.key_name
}

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
      aws_ssm_parameter.cobudget_cors_origins.arn,
      aws_ssm_parameter.cobudget_oauth_issuer.arn,
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
      image        = "${aws_ecr_repository.aws_ecr_cobudget.repository_url}:latest"
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
        }
      ]
      secrets = [
        {
          name      = "CORS_ORIGINS"
          valueFrom = aws_ssm_parameter.cobudget_cors_origins.arn
        },
        {
          name      = "OAUTH_ISSUER"
          valueFrom = aws_ssm_parameter.cobudget_oauth_issuer.arn
        },
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