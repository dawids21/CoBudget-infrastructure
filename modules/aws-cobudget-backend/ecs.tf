resource "aws_security_group" "cobudget_ecs" {
  vpc_id = aws_vpc.cobudget.id
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
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

resource "aws_instance" "cobudget" {
  ami                         = data.aws_ami.cobudget.id
  iam_instance_profile        = aws_iam_instance_profile.ecs_agent.name
  vpc_security_group_ids      = [aws_security_group.cobudget_ecs.id]
  instance_type               = "t2.micro"
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=my-cluster >> /etc/ecs/ecs.config"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.cobudget_public.id
}

resource "aws_ecs_cluster" "cobudget" {
  name = "my-cluster"
}

resource "aws_ecs_task_definition" "cobudget" {
  container_definitions = jsonencode([
    {
      essential   = true
      memory      = 512
      name        = "cobudget"
      image       = "${aws_ecr_repository.aws_ecr_cobudget.repository_url}:latest"
      environment = []
    }
  ])
  family = "cobudget"
}