locals {
  env = {
    default = {
      aws_region   = "eu-central-1"
      heroku_email = "dawid.stasiak21@gmail.com"
    }
    prod = {
      app_domain           = "cobudget.stasiak.xyz"
      app_backend_domain   = "cobudget-backend.stasiak.xyz"
      okta_org_name        = "dev-01647397"
      okta_base_url        = "okta.com"
      aws_vpc_cidr         = "10.0.0.0/22"
      aws_vpc_cidr_public  = ["10.0.0.0/24"]
      aws_vpc_cidr_private = ["10.0.1.0/24", "10.0.2.0/24"]
    }
  }
  environment = contains(keys(local.env), var.environment) ? var.environment : "default"
  workspace   = merge(local.env.default, local.env[local.environment])
}
