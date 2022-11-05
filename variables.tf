variable "vercel_api_token" {
  description = "Token to interact with Vercel API"
  type        = string
  sensitive   = true
}

variable "heroku_api_key" {
  description = "API key to authenticate Heroku API"
  type        = string
  sensitive   = true
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