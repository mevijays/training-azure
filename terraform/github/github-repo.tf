terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.25.1"
    }
  }
  backend "http" {}
}

provider "github" {
 token  = var.G_TOKEN
 owner  = "mevijays"
}

variable "G_TOKEN" {
  type = string
}


resource "github_repository" "example" {
  count = length(var.repos)
  for_each = toset(var.repos)
  name        = each.key
  description = "My awesome codebase"
  visibility  = "public"
  auto_init   = true
}
