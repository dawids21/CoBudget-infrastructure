// heroku_addon for database
// heroku_app_config_association for linking app with config vars
// heroku_formation for creating dyno

resource "heroku_app" "backend" {
  name   = "heroku-test"
  region = "eu"
}

resource "heroku_config" "backend_config_vars" {
  vars = {
    "APP_PORT"     = "8080"
    "CORS_ORIGINS" = var.frontend_url
    "OAUTH_ISSUER" = var.oauth_issuer
  }
}