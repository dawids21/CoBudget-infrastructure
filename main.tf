module "vercel_cobudget_frontend" {
  source = "./modules/vercel-cobudget-frontend"

  app_domain     = module.vars.env["app_domain"]
  okta_issuer    = module.okta_cobudget_iaas.okta_issuer
  okta_client_id = module.okta_cobudget_iaas.okta_client_id
  backend_url    = "https://cobudget-backend.stasiak.xyz/"
}

module "heroku_cobudget_backend" {
  source = "./modules/heroku-cobudget-backend"

  frontend_url = "https://${module.vars.env["app_domain"]}"
  oauth_issuer = module.okta_cobudget_iaas.okta_issuer
}

module "okta_cobudget_iaas" {
  source = "./modules/okta-cobudget-iaas"

  redirect_uris = [
    "https://cobudget.stasiak.xyz/login/callback",
    "http://localhost:3000/login/callback"
  ]
  post_logout_redirect_uris = ["http://localhost:3000", "https://cobudget.stasiak.xyz"]
  logo_path                 = "./logo.png"
  prod_user_password        = var.okta_prod_user_password
}

module "aws_cobudget_backend" {
  source           = "./modules/aws-cobudget-backend"
  env              = terraform.workspace
  region           = module.vars.env["aws_region"]
  db_password      = var.db_password
  frontend_url     = "https://${module.vars.env["app_domain"]}"
  backend_url      = module.vars.env["app_backend_domain"]
  oauth_issuer     = module.okta_cobudget_iaas.okta_issuer
  vpc_cidr         = module.vars.env["aws_vpc_cidr"]
  vpc_cidr_public  = module.vars.env["aws_vpc_cidr_public"]
  vpc_cidr_private = module.vars.env["aws_vpc_cidr_private"]
  cluster_name     = module.vars.env["aws_cluster_name"]
}

module "vars" {
  source      = "./modules/vars"
  environment = terraform.workspace
}