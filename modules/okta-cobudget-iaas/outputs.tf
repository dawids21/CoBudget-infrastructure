output "okta_client_id" {
  description = "Client ID for OIDC"
  value       = okta_app_oauth.oauth.id
}