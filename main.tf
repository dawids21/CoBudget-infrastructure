module "vercel_cobudget_frontend" {
  source = "./modules/vercel-cobudget-frontend"

  app_domain     = var.app_domain
  okta_issuer    = var.vercel_okta_issuer
  okta_client_id = var.vercel_okta_client_id
  backend_url    = module.heroku_cobudget_backend.backend_url
}

module "heroku_cobudget_backend" {
  source = "./modules/heroku-cobudget-backend"

  frontend_url = "https://${var.app_domain}"
  oauth_issuer = var.vercel_okta_issuer
}

module "okta_cobudget_iaas" {
  source = "./modules/okta-cobudget-iaas"
}