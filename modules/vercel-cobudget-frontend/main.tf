locals {
  default_env_target = [
    "development",
    "preview",
    "production"
  ]
}

resource "vercel_project" "frontend_project" {
  name    = "co-budget-frontend"
  team_id = "dawids21"
  git_repository = {
    repo = "dawids21/CoBudget-frontend"
    type = "github"
  }
  framework = "vue"
  environment = [
    {
      key   = "VUE_APP_OKTA_URI"
      value = var.okta_uri
      target = local.default_env_target
    },
    {
      key   = "VUE_APP_OKTA_CLIENT_ID"
      value = var.okta_client_id
      target = local.default_env_target
    },
    {
      key   = "VUE_APP_OKTA_REDIRECT_URI"
      value = var.okta_redirect_uri
      target = local.default_env_target
    },
    {
      key   = "VUE_APP_BACKEND_URL"
      value = var.backend_url
      target = local.default_env_target
    },
    {
      key   = "VUE_APP_BACKEND_TIMEOUT"
      value = "40000"
      target = local.default_env_target
    }
  ]
}