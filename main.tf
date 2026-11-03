locals {
  team_permissions = {
    developers = "push"
    testers    = "pull"
    devops     = "push"
  }
  memberships = merge([
    for team, users in var.team_members : {
      for user in users : "${team}/${user}" => { team = team, user = user }
    }
  ]...)
}
resource "github_team" "roles" {
  for_each = local.team_permissions
  name     = each.key
  privacy  = "closed"
}
resource "github_team_membership" "members" {
  for_each = local.memberships
  team_id  = github_team.roles[each.value.team].id
  username = each.value.user
  role     = "member"
}
module "repository_security" {
  for_each         = var.repositories
  source           = "./modules/repository-security"
  github_owner     = var.github_owner
  repository       = each.key
  branch           = each.value.branch
  enforce_pr_rules = each.value.enforce_pr_rules
  team_ids         = { for k, v in github_team.roles : k => v.id }
  codeowner_slug   = github_team.roles["devops"].slug
  depends_on       = [github_team_membership.members]
}
