terraform {
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 0.3.0"
    }
    heroku = {
      source  = "heroku/heroku"
      version = "~> 5.0.2"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 3.35.0"
    }
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  required_version = "~> 1.3.0"

  cloud {
    organization = "dawids21"
    workspaces {
      name = "CoBudget"
    }
  }
}

provider "vercel" {
  api_token = var.vercel_api_token
}

provider "heroku" {
  email   = var.heroku_email
  api_key = var.heroku_api_key
}

provider "okta" {
  org_name  = var.okta_org_name
  base_url  = var.okta_base_url
  api_token = var.okta_api_token
}

provider "aws" {
  region = var.aws_region
}