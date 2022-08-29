variable "account_roles" {
  description = "Roles for TF to assume into the relevant account based on the workspace"
  type        = map(string)
}
