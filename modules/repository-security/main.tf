# Reads an existing repository; does not create or own the repository itself.
data "github_repository" "existing" {
  full_name = "${var.github_owner}/${var.repository}"
}
resource "github_team_repository" "access" {
  for_each   = { developers = "push", testers = "pull", devops = "push" }
  team_id    = var.team_ids[each.key]
  repository = data.github_repository.existing.name
  permission = each.value
}
# Bootstrap these files before activating PR rules.
# Subsequent file changes belong in reviewed PRs, not direct Terraform writes.
resource "github_repository_file" "workflow" {
  repository          = data.github_repository.existing.name
  branch              = var.branch
  file                = ".github/workflows/unit-tests.yml"
  content             = file("${path.module}/../../templates/unit-tests.yml")
  commit_message      = "Bootstrap required unit test workflow"
  overwrite_on_create = false
  lifecycle {
    ignore_changes = [content]
    prevent_destroy = true
  }
}
resource "github_repository_file" "codeowners" {
  repository          = data.github_repository.existing.name
  branch              = var.branch
  file                = ".github/CODEOWNERS"
  content             = "* @${var.github_owner}/${var.codeowner_slug}\n"
  commit_message      = "Bootstrap mandatory code owners"
  overwrite_on_create = false
  depends_on          = [github_team_repository.access]
  lifecycle {
    ignore_changes = [content]
    prevent_destroy = true
  }
}
# Separate rule so force pushes are prohibited on feature branches too.
resource "github_repository_ruleset" "no_force_push" {
  name        = "terraform-no-force-push"
  repository  = data.github_repository.existing.name
  target      = "branch"
  enforcement = "active"
  conditions {
    ref_name {
      include = ["~ALL"]
      exclude = []
    }
  }
  rules {
    non_fast_forward = true
  }
}
resource "github_repository_ruleset" "merge_gate" {
  name        = "terraform-reviewed-tested-merges"
  repository  = data.github_repository.existing.name
  target      = "branch"
  enforcement = var.enforce_pr_rules ? "active" : "disabled"
  conditions {
    ref_name {
      include = ["refs/heads/${var.branch}"]
      exclude = []
    }
  }
  # No bypass actors: administrators have no configured merge bypass.
  rules {
    deletion = true
    pull_request {
      required_approving_review_count   = 1
      require_code_owner_review         = true
      dismiss_stale_reviews_on_push     = true
      require_last_push_approval        = true
      required_review_thread_resolution = true
    }
    required_status_checks {
      strict_required_status_checks_policy = true
      required_check {
        context = "unit-tests"
        # Public GitHub.com GitHub Actions App ID. Verify for other environments.
        integration_id = 15368
      }
    }
  }
  depends_on = [github_repository_file.workflow, github_repository_file.codeowners]
}
