output "role_names" {
  description = "Map of created role names."
  value       = { for k, v in aws_iam_role.this : k => v.name }
}

output "role_arns" {
  description = "Map of created role ARNs."
  value       = { for k, v in aws_iam_role.this : k => v.arn }
}
