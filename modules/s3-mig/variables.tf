variable "aws_region" {
  description = "AWS region"
  type        = string
}
# when we move to govcloud default region could change "us-gov-west-1"

variable "enable_versioning" {
  description = "Enable versioning on the S3 bucket"
  type        = bool
  default     = true
}

variable "sse_algorithm" {
  description = "Server-side encryption algorithm (e.g., AES256 or aws:kms)"
  type        = string
  default     = "AES256"
}

variable "organization" {
  description = "Company or organization prefix"
  type        = string
}

variable "team" {
  description = "Team or project name"
  type        = string
}
variable "env" {
  description = "Deployment environment (dev, uat, prod)"
  type        = string
}

variable "resource_type" {
  description = "Type of resource (e.g., s3, rds, ec2)"
  type        = string
  default     = "s3"
}

variable "purpose" {
  description = "The functional purpose of the bucket"
  type        = string
}