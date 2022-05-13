locals {
  default_env_target = [
    "development",
    "preview",
    "production"
  ]
}

resource "vercel_project" "frontend" {
  name    = "co-budget-frontend"
  team_id = "dawids21"
  git_repository = {
    repo = "dawids21/CoBudget-frontend"
    type = "github"
  }
  framework = "vue"
  environment = [
    {
      key    = "VUE_APP_OKTA_URI"
      value  = var.okta_uri
      target = local.default_env_target
    },
    {
      key    = "VUE_APP_OKTA_CLIENT_ID"
      value  = var.okta_client_id
      target = local.default_env_target
    },
    {
      key    = "VUE_APP_OKTA_REDIRECT_URI"
      value  = var.okta_redirect_uri
      target = local.default_env_target
    },
    {
      key    = "VUE_APP_BACKEND_URL"
      value  = var.backend_url
      target = local.default_env_target
    },
    {
      key    = "VUE_APP_BACKEND_TIMEOUT"
      value  = "40000"
      target = local.default_env_target
    }
  ]
}

resource "vercel_project_domain" "frontend" {
  domain     = var.app_domain
  project_id = vercel_project.frontend.id
  team_id    = "dawids21"
}

data "vercel_project" "frontend" {
  depends_on = [
    vercel_project.frontend
  ]
  name    = "co-budget-frontend"
  team_id = "dawids21"
}

data "vercel_project_directory" "frontend" {
  path = "../frontend"
}

resource "vercel_deployment" "frontend" {
  project_id  = data.vercel_project.frontend.id
  files       = data.vercel_project_directory.frontend.files
  production  = true
  path_prefix = data.vercel_project_directory.frontend.path
  team_id     = "dawids21"
}