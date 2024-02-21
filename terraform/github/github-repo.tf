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
  template {
    owner                = "mevijays"
    repository           = each.key
    include_all_branches = true
  }
}
resource "github_branch_protection_v3" "main" {
  for_each = toset(var.repos)
  repository = each.key
  branch         = "main"
  required_pull_request_reviews {
    require_code_owner_reviews = true
    required_approving_review_count = 1
  }
  depends_on = [ github_repository.main ]
}
