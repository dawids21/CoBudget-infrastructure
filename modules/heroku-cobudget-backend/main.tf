resource "heroku_app" "backend" {
  name   = "dawids21-heroku-test"
  region = "eu"
}

resource "heroku_build" "backend" {
  app_id = heroku_app.backend.id

  source {
    path = "../backend"
  }
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
  depends_on = [
    heroku_build.backend
  ]
}

resource "heroku_addon" "backend-database" {
  app_id = heroku_app.backend.id
  plan   = "heroku-postgresql:hobby-dev"
  name   = "cobudget-backend-database"
}