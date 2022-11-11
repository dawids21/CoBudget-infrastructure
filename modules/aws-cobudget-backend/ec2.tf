resource "aws_security_group" "cobudget_ecs" {
  name   = "cobudget-ecs"
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

resource "aws_iam_instance_profile" "cobudget_ecs_agent" {
  name = "ecs-agent"
  role = aws_iam_role.cobudget_ecs_agent.name
}

data "aws_ami" "cobudget" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_key_pair" "cobudget" {
  key_name   = "cobudget"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDV9brHJCm7kD7yJ56DEjhU7sckMLa/wj3tWGuyhHjma0grspV6fyAgPaBzZq1RX0sujlgdIBR4b1i9fIUrcp4OcdZLaxdupJbUvew8BqwWgJnmjuwSvhrrHPdweJK5LIE82SYakM0ptBWpRzaRLGoz9P71ElVRIPtVYDAbHSrHrxy7jX5H+7ExTkKcUDYeGXaeAlzxNM6qDaoPI9APX2MbR/L6HzrwbfiUb6U8jLqJOYghCwwl8A6DjaTBBGqDMDcT5yjMF0Y39hNTfrYzxQ6V6Uq6+WEHLnE+WLUlblvwJtMhfsQvmFQybROsGY5clUa+6pW7V7TAHL8RuG7LufmpvgQK0ci2ummeIYGk6IZQHAl+9HFgnHDqe/ZpTFewnfeb2kpZIweogWpzouAjIuWmRXn2kuKggy1p45BbPnXOhyFGZlkJhoHO0iqrbWL5N8RWZ1JjviJrQo2QN5Iqo6q7hzbeCxAH2Ksvn+bgnZCGtBfjXejfOk+vKXxlBHMJh58= dawids@dawid-ms7d43"
}

resource "aws_instance" "cobudget" {
  ami                         = data.aws_ami.cobudget.id
  iam_instance_profile        = aws_iam_instance_profile.cobudget_ecs_agent.name
  vpc_security_group_ids      = [aws_security_group.cobudget_ecs.id]
  instance_type               = "t2.micro"
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${var.cluster_name} >> /etc/ecs/ecs.config"
  associate_public_ip_address = true
  subnet_id                   = aws_subnet.cobudget_public[var.vpc_cidr_public[0]].id
  key_name                    = aws_key_pair.cobudget.key_name
  lifecycle {
    ignore_changes = [ami]
  }
}
