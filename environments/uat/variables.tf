# variable "lambda_role_arn" {
#   description = "Execution role ARN for the UAT Lambda function"
#   type        = string
# }

variable "region" {
  description = "AWS region"
  type        = string
}

variable "organization" {
  description = "Organization name"
  type        = string
}

variable "team" {
  description = "Team name"
  type        = string
}

variable "env" {
  description = "Environment name"
  type        = string
}