variable "vercel_api_token" {
  description = "Token to interact with Vercel API"
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

variable "registry_password" {
  description = "Password for the private registry"
  type        = string
  sensitive   = true
}