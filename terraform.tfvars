github_owner = "YOUR-GITHUB-ORGANISATION"
team_members = {
  developers = ["developer-login"]
  testers    = ["tester-login"]
  devops     = ["reviewer-login"]
}
repositories = {
  mytestRepo = {
    branch           = "main"
    enforce_pr_rules = false # Set true after bootstrap and a successful check run.
  }
  # anotherRepo = { branch = "main", enforce_pr_rules = false }
}
