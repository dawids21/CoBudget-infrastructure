variable "app_domain" {
  description = "Domain of the frontend app"
  type        = string
}

variable "okta_uri" {
  description = "Okta OIDC URI"
  type        = string
  sensitive   = true
}

variable "okta_client_id" {
  description = "Okta OIDC Client ID"
  type        = string
  sensitive   = true
}

variable "okta_redirect_uri" {
  description = "Okta OIDC redirect URI"
  type        = string
  sensitive   = true
}

variable "backend_url" {
  description = "Backend app url"
  type        = string
}