#resource "okta_app_oauth" "oauth" {
#  label = "Okta Terraform Example"
#  type  = "browser"
#
#  grant_types                = ["authorization_code", "refresh_token"]
#  redirect_uris              = var.redirect_uris
#  post_logout_redirect_uris  = var.post_logout_redirect_uris
#  token_endpoint_auth_method = "none"
#  refresh_token_rotation     = "ROTATE"
#  consent_method             = "REQUIRED"
#}