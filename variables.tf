variable "vercel_api_token" {
  description = "Token to interact with Vercel API"
  type        = string
  sensitive   = true
}

variable "vercel_okta_uri" {
  description = "Okta OIDC URI"
  type        = string
}

variable "vercel_okta_client_id" {
  description = "Okta OIDC Client ID"
  type        = string
}

variable "vercel_okta_redirect_uri" {
  description = "Okta OIDC redirect URI"
  type        = string
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