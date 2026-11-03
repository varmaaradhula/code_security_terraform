terraform {
  required_version = ">= 1.5.0"
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.10.2"
    }
  }
}
provider "github" {
  owner = var.github_owner
}
