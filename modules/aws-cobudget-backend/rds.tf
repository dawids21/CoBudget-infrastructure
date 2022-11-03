resource "aws_db_instance" "cobudget" {
  allocated_storage   = 5
  identifier_prefix   = "cobudget"
  db_name             = "cobudget"
  engine              = "postgres"
  instance_class      = "db.t4g.micro"
  username            = "cobudget"
  password            = var.db_password
  multi_az            = false
  skip_final_snapshot = true
}