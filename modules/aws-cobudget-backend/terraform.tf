terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}