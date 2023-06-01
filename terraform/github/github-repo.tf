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
 token  = var.GITHUB_TOKEN
 owner  = "mevijays"
}

variable "GITHUB_TOKEN" {
  type = string
}


resource "github_repository" "example" {
  name        = "example"
  description = "My awesome codebase"
  visibility  = "public"
  auto_init   = true
}
