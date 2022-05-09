module "vercel_cobudget_frontend" {
  source = "./modules/vercel-cobudget-frontend"

  okta_uri          = var.vercel_okta_uri
  okta_client_id    = var.vercel_okta_client_id
  okta_redirect_uri = var.vercel_okta_redirect_uri
  backend_url       = var.vercel_backend_url
}