terraform {
  cloud {}

  required_providers {
    github = {
      source  = "integrations/github"
      version = "5.42.0"
    }
  }
}

provider "github" {}

variable "repositories" {
  default = []
}

resource "github_repository" "repos" {
  for_each    = var.repositories
  name        = each.key
  description = each.value.description
  visibility  = "public"

  allow_merge_commit          = false
  allow_rebase_merge          = false
  allow_squash_merge          = true
  squash_merge_commit_title   = "PR_TITLE"
  squash_merge_commit_message = "PR_BODY"

  has_issues = true
}

resource "github_branch_protection" "main_branch" {
  for_each      = var.repositories
  repository_id = github_repository.repos[each.key].node_id
  pattern       = "main"

  dynamic "required_status_checks" {
    for_each = lookup(var.repositories[each.key], "statusCheck", false) ? [""] : []
    content {
      strict = true
    }
  }
}
