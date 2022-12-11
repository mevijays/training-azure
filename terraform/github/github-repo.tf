terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.12.0"
    }
  }
  backend "http" {}
}

provider "github" {
  # Configuration options
  owner  = "mevijays"
  token  = var.TOKEN
}

resource "github_repository" "example" {
  name        = "example"
  description = "My awesome codebase"
  visibility  = "public"
  auto_init   = true
}
