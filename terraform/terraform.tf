terraform {
  cloud {
    organization = "jonas"
    workspaces {
      name = "github-repositories"
    }
  }

  required_providers {
    doppler = {
      source  = "DopplerHQ/doppler"
      version = "1.7.1"
    }

    github = {
      source  = "integrations/github"
      version = "5.42.0"
    }
  }
}

provider "github" {}

provider "doppler" {}

variable "repositories" {
  default = []
}

locals {
  // Contain all repository variables in a map structure
  repo_variables = merge([
    // Loop over all variables in each repository
    for repoName, repo in var.repositories : {
      for key, value in lookup(repo, "variables", {}) : "${repoName}-${key}" => {
        repo  = repoName
        key   = key
        value = value
      }
    }
  ]...)

  // Contain all repository secrets in a map structure
  repo_secrets = merge([
    // Loop over all secrets in each repository
    for repoName, repo in var.repositories : {
      for key, value in lookup(repo, "secrets", {}) : "${repoName}-${key}" => {
        repo  = repoName
        key   = key
        value = value
      }
    }
  ]...)
}

data "doppler_secrets" "this" {}

// All github repositories
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

# Basic main branch protection rule
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

# Github actions variables
resource "github_actions_variable" "variable" {
  for_each      = local.repo_variables
  repository    = github_repository.repos[each.value.repo].name
  variable_name = each.value.key
  value         = each.value.value
}

# Github actions secrets
resource "github_actions_secret" "secret" {
  for_each        = local.repo_secrets
  repository      = github_repository.repos[each.value.repo].name
  secret_name     = each.value.key
  plaintext_value = data.doppler_secrets.this.map[each.value.value]
}
