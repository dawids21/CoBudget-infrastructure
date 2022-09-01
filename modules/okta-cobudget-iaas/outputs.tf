output "okta_client_id" {
  description = "Client ID for OIDC"
  value       = okta_app_oauth.oauth.id
}

output "okta_issuer" {
  description = "Issuer URI for OIDC"
  value       = okta_auth_server_default.oauth.issuer
}