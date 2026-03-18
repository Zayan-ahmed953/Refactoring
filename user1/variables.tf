variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "enable_versioning" {
  description = "enabling versioning"
  type        = bool
}

variable "sse_algorithm" {
  description = "encrypt s3 data"
  type        = string
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

variable "s3_buckets" {
  type = map(object({
    purpose = string
  }))
  description = "Map of S3 bucket configurations"
}


