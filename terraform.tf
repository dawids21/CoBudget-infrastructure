terraform {
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 0.3.0"
    }
    okta = {
      source  = "okta/okta"
      version = "~> 3.35.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }

  required_version = "~> 1.0"

  backend "s3" {
    bucket         = "dawids21free-terraform-state"
    key            = "terraform/cobudget/terraform.tfstate"
    region         = "eu-central-1"
    dynamodb_table = "TerraformStateLocks"
    encrypt        = true
  }
}

provider "vercel" {
  api_token = var.vercel_api_token
}

provider "okta" {
  org_name  = module.vars.env["okta_org_name"]
  base_url  = module.vars.env["okta_base_url"]
  api_token = var.okta_api_token
}

provider "aws" {
  region = module.vars.env["aws_region"]
}

provider "github" {
  token = var.github_token
}