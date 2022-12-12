terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "5.12.0"
    }
  }
  backend "http" {}
}
variable "TOKEN" {}

provider "github" {}

resource "github_repository" "example" {
  name        = "example"
  description = "My awesome codebase"
  visibility  = "public"
  auto_init   = true
}
