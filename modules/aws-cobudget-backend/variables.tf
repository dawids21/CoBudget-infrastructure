variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "vpc_cidr_public" {
  description = "CIDR blocks for public subnets in VPC"
  type        = list(string)
}

variable "vpc_cidr_private" {
  description = "CIDR blocks for private subnets in VPC"
  type        = list(string)
}

variable "db_password" {
  description = "Password to DB"
  type        = string
  sensitive   = true
}

variable "frontend_url" {
  description = "URL of the frontend app"
  type        = string
}

variable "oauth_issuer" {
  description = "Issuer URL for OAuth2"
  type        = string
}