terraform {
  required_providers {
    github = {
      source = "integrations/github"
      version = "~> 6.0"
    }
  }
  cloud {
    organization = "mevijays"

    workspaces {
      name = "github-repo"
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
  for_each = var.repos
  name               = each.key
  description        = "My awesome codebase in ${ each.key}"
  visibility         = each.value
  auto_init          = true
  has_issues         = false
  has_discussions    = false
  has_wiki           = false
  has_projects       = false
  gitignore_template = "Terraform"
  default_branch     = "main"
}

resource "github_branch_protection_v3" "main" {
  for_each   = var.repos
  repository = each.key
  branch     = "main"
  required_pull_request_reviews {
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
  depends_on = [ github_repository.main ]
}

resource "github_branch" "this" {
  for_each   = var.repos
  repository = each.key
  branch     = "develop"
  depends_on = [ github_repository.main ]
}

resource "github_branch_protection_v3" "develop" {
  for_each   = var.repos
  repository = each.key
  branch     = "develop"
  required_pull_request_reviews {
    require_code_owner_reviews      = true
    required_approving_review_count = 1
  }
  depends_on = [ github_repository.main , github_branch.this ]
}

