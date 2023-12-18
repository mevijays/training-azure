variable "repos" {
  type = list
  default = ["repo1", "repo2"]
}
variable "repo_visibility" {
  type = string
  default = "public"
}