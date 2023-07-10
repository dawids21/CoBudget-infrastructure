module "vercel_cobudget_frontend" {
  source = "./modules/vercel-cobudget-frontend"

  app_domain     = module.vars.env["app_domain"]
  okta_issuer    = module.okta_cobudget_iaas.okta_issuer
  okta_client_id = module.okta_cobudget_iaas.okta_client_id
  backend_url    = "https://cobudget-backend.stasiak.xyz/"
}

module "okta_cobudget_iaas" {
  source = "./modules/okta-cobudget-iaas"

  redirect_uris = [
    "https://cobudget.stasiak.xyz/login/callback",
    "http://localhost:3000/login/callback",
    "http://${module.vars.env["app_backend_domain"]}/swagger-ui/oauth2-redirect.html",
    "https://${module.vars.env["app_backend_domain"]}/swagger-ui/oauth2-redirect.html"
  ]
  post_logout_redirect_uris = ["http://localhost:3000", "https://cobudget.stasiak.xyz"]
  logo_path                 = "./logo.png"
  prod_user_password        = var.okta_prod_user_password
}

module "cobudget_backend" {
  source            = "./modules/cobudget-backend"
  registry_username = module.vars.env["registry_username"]
  registry_password = var.registry_password
}

module "vars" {
  source      = "./modules/vars"
  environment = terraform.workspace
}