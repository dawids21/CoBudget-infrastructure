variable "app_domain" {
  description = "Domain of the frontend app"
  type        = string
}

variable "okta_issuer" {
  description = "Okta OIDC issuer"
  type        = string
}

variable "okta_client_id" {
  description = "Okta OIDC Client ID"
  type        = string
}

variable "backend_url" {
  description = "Backend app url"
  type        = string
}