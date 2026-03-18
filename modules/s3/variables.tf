variable "standard_bucket_name" {
  description = "Name of the standard S3 bucket"
  type        = string
}

variable "glacier_bucket_name" {
  description = "Name of the glacier S3 bucket"
  type        = string
}

variable "tags" {
  description = "Common tags for all buckets"
  type        = map(string)
  default     = {}
}
