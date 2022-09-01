resource "okta_app_oauth" "oauth" {
  label = "CoBudget"
  type  = "browser"

  grant_types                = ["authorization_code", "refresh_token"]
  redirect_uris              = var.redirect_uris
  post_logout_redirect_uris  = var.post_logout_redirect_uris
  token_endpoint_auth_method = "none"
  consent_method             = "REQUIRED"
  response_types             = ["code"]
  logo                       = var.logo_path
  accessibility_self_service = true

  lifecycle {
    ignore_changes = [groups]
  }
}

resource "okta_group" "oauth" {
  name = "CoBudget-prod"
}

resource "okta_app_group_assignment" "oauth" {
  app_id   = okta_app_oauth.oauth.id
  group_id = okta_group.oauth.id
}

resource "okta_user" "admin" {
  email      = "cobudget.prod@stasiak.xyz"
  login      = "cobudget.prod@stasiak.xyz"
  first_name = "Super"
  last_name  = "User"
  password   = var.prod_user_password
}

resource "okta_group_memberships" "oauth" {
  group_id = okta_group.oauth.id
  users    = [okta_user.admin.id]
}

resource "okta_auth_server_default" "oauth" {
  name                      = "default"
  audiences                 = ["api://default"]
  credentials_rotation_mode = "AUTO"
}