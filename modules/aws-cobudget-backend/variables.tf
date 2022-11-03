variable "region" {
  description = "AWS region"
  type        = string
}

variable "db_password" {
  description = "Password to DB"
  type        = string
  sensitive   = true
}