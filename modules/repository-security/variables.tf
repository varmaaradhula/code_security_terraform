variable "github_owner" { type = string }
variable "repository" { type = string }
variable "branch" { type = string }
variable "enforce_pr_rules" { type = bool }
variable "team_ids" { type = map(string) }
variable "codeowner_slug" { type = string }