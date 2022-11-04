variable "region" {
  description = "AWS region"
  type        = string
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