variable "vercel_api_token" {
  description = "Token to interact with Vercel API"
  type        = string
  sensitive   = true
}

variable "heroku_email" {
  description = "Email to authenticate Heroku API"
  type        = string
  sensitive   = true
}

variable "heroku_api_key" {
  description = "API key to authenticate Heroku API"
  type        = string
  sensitive   = true
}

variable "app_domain" {
  description = "Domain of the frontend app"
  type        = string
}

variable "okta_org_name" {
  description = "Name of the Okta organization"
  type        = string
}

variable "okta_base_url" {
  description = "Domain of the Okta account"
  type        = string
}

variable "okta_api_token" {
  description = "Token for Okta API"
  type        = string
  sensitive   = true
}

variable "okta_prod_user_password" {
  description = "Password for the production user"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "Region for AWS"
  type        = string
}

variable "github_token" {
  description = "Personal access token for GitHub"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Password to DB"
  type        = string
  sensitive   = true
}