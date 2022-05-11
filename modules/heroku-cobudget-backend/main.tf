// heroku_addon for database
// heroku_app for app
// heroku_config for config vars
// heroku_app_config_association for linking app with config vars
// heroku_formation for creating dyno

resource "heroku_config" "backend_config_vars" {
  vars = {
    "APP_PORT"     = "8080"
    "CORS_ORIGINS" = var.frontend_url
    "OAUTH_ISSUER" = var.oauth_issuer
  }
}