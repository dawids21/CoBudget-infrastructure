resource "aws_security_group" "cobudget_rds" {
  name   = "cobudget-rds"
  vpc_id = aws_vpc.cobudget.id
  ingress {
    from_port       = 5432
    protocol        = "tcp"
    to_port         = 5432
    cidr_blocks     = ["0.0.0.0/0"]
    security_groups = [aws_security_group.cobudget_ecs.id]
  }
  egress {
    from_port   = 0
    protocol    = "tcp"
    to_port     = 65535
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_subnet_group" "cobudget" {
  name       = "cobudget-db-subnet-group"
  subnet_ids = values(aws_subnet.cobudget_private)[*].id
}

resource "aws_db_instance" "cobudget" {
  allocated_storage      = 5
  identifier_prefix      = "cobudget"
  db_name                = "cobudget"
  engine                 = "postgres"
  instance_class         = "db.t4g.micro"
  username               = "cobudget"
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.cobudget_rds.id]
  db_subnet_group_name   = aws_db_subnet_group.cobudget.name
  multi_az               = false
  skip_final_snapshot    = true
}

resource "aws_ssm_parameter" "cobudget_jdbc_database_url" {
  name  = "cobudget-jdbc-database-url"
  type  = "SecureString"
  value = "jdbc:postgresql://${aws_db_instance.cobudget.endpoint}/${aws_db_instance.cobudget.db_name}"
}

resource "aws_ssm_parameter" "cobudget_jdbc_database_username" {
  name  = "cobudget-jdbc-database-username"
  type  = "SecureString"
  value = aws_db_instance.cobudget.username
}

resource "aws_ssm_parameter" "cobudget_jdbc_database_password" {
  name  = "cobudget-jdbc-database-password"
  type  = "SecureString"
  value = aws_db_instance.cobudget.password
}
