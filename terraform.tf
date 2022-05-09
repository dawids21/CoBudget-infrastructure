terraform {
  required_providers {

  }

  required_version = "~> 1.1.0"

  cloud {
    organization = "dawids21"
    workspaces {
      name = "CoBudget"
    }
  }
}