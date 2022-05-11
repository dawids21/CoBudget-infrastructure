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

resource "heroku_app_config_association" "backend" {
  app_id = heroku_app.backend.id

  vars = heroku_config.backend_config_vars.vars
}

resource "heroku_formation" "backend" {
  app_id   = heroku_app.backend.id
  type     = "web"
  quantity = 1
  size     = "free"
}

resource "heroku_addon" "backend-database" {
  app_id = heroku_app.backend.id
  plan   = "hobby-dev"
  name   = "cobudget-backend-database"
}