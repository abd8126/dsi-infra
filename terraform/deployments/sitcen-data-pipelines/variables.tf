variable "account_roles" {
  description = "Roles for TF to assume into the relevant account based on the workspace"
  type        = map(string)
}

variable "python_libraries_files" {
  type    = list(any)
  default = ["importlib_resources-5.4.0-py3-none-any.whl", "jsonschema-4.4.0-py3-none-any.whl", "pyrsistent-0.18.1-cp310-cp310-win_amd64.whl"]
}
