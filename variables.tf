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
