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
 token  = var.gtoken
 owner  = "mevijays"
}

}

resource "github_repository" "example" {
  name        = "example"
  description = "My awesome codebase"
  visibility  = "public"
  auto_init   = true
}
