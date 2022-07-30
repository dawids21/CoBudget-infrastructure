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
  }

  required_version = "~> 1.2.0"

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