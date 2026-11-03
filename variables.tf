variable "github_owner" {
  type = string
}
variable "team_members" {
  description = "Existing organisation members, by GitHub login. Keep role lists disjoint."
  type = object({
    developers = set(string)
    testers    = set(string)
    devops     = set(string)
  })
  validation {
    condition = (
      length(setintersection(var.team_members.developers, var.team_members.testers)) == 0 &&
      length(setintersection(var.team_members.developers, var.team_members.devops)) == 0 &&
      length(setintersection(var.team_members.testers, var.team_members.devops)) == 0
    )
    error_message = "Use different users in each team for this POC."
  }
}
variable "repositories" {
  type = map(object({
    branch           = optional(string, "main")
    enforce_pr_rules = optional(bool, false)
  }))
}
