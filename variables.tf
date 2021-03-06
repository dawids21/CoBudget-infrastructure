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

variable "vercel_okta_issuer" {
  description = "Okta OIDC issuer"
  type        = string
}

variable "vercel_okta_client_id" {
  description = "Okta OIDC Client ID"
  type        = string
}