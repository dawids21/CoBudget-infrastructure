terraform {
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 0.3.0"
    }
  }

  required_version = "~> 1.1.0"

  cloud {
    organization = "dawids21"
    workspaces {
      name = "CoBudget"
    }
  }
}