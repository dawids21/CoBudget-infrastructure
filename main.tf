module "vercel_cobudget_frontend" {
  source = "./modules/vercel-cobudget-frontend"

  okta_uri          = var.vercel_okta_uri
  okta_client_id    = var.vercel_okta_client_id
  okta_redirect_uri = var.vercel_okta_redirect_uri
  backend_url       = module.heroku_cobudget_backend.backend_url
}

module "heroku_cobudget_backend" {
  source = "./modules/heroku-cobudget-backend"

  frontend_url = module.vercel_cobudget_frontend.frontend_url
  oauth_issuer = "${var.vercel_okta_uri}/oauth2/default"
}