variable "roles" {
  description = "Map of IAM roles to create. Key is role name. Supported keys per role: description, path, max_session_duration, assume_role_services (list), assume_role_arns (list), managed_policy_names (list), inline_policies (map of policy_name => json), tags (map)."
  type        = map(any)
  default     = {}

  validation {
    condition = alltrue([
      for role in values(var.roles) :
      length(try(role.assume_role_services, [])) + length(try(role.assume_role_arns, [])) > 0
    ])
    error_message = "Each role must define at least one trust principal using assume_role_services and/or assume_role_arns."
  }
}

variable "tags" {
  description = "Common tags applied to all IAM roles."
  type        = map(string)
  default     = {}
}
