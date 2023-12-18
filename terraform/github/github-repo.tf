terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "~> 5.0"
    }
  }
  cloud {
    organization = "mevijays"

    workspaces {
      name = "training-azure"
    }
  }
}
provider "github" {
 token  = var.G_TOKEN
 owner  = "mevijays"
}

variable "G_TOKEN" {
  type = string
}


resource "github_repository" "main" {
  for_each = toset(var.repos)
  name        = each.key
  description = "My awesome codebase"
  visibility  = var.repo_visibility
  auto_init   = true
}
resource "github_branch_protection_v3" "main" {
  repository     = github_repository.main
  branch         = "main"
  required_pull_request_reviews {
    require_code_owner_reviews = true
    required_approving_review_count = 1
  }
}
