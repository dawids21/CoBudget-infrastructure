locals {
  env = {
    default = {
      registry_username = "dawids21"
    }
    prod = {
      app_domain         = "cobudget.stasiak.xyz"
      app_backend_domain = "cobudget-backend.stasiak.xyz"
      okta_org_name      = "dev-01647397"
      okta_base_url      = "okta.com"
    }
  }
  environment = contains(keys(local.env), var.environment) ? var.environment : "default"
  workspace   = merge(local.env.default, local.env[local.environment])
}
