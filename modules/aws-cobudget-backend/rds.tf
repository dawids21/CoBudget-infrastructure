resource "aws_security_group" "cobudget_rds" {
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
}

resource "aws_db_subnet_group" "cobudget" {
  name       = "postgres-subnet-group"
  subnet_ids = [aws_subnet.cobudget_private.id, aws_subnet.cobudget_private2.id]
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
  value = "cobudget"
}

resource "aws_ssm_parameter" "cobudget_jdbc_database_password" {
  name  = "cobudget-jdbc-database-password"
  type  = "SecureString"
  value = var.db_password
}
