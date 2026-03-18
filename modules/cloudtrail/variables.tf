variable "company" {
  description = "Company prefix (e.g., sp)"
  type        = string
}
variable "team" {
  description = "Team name (e.g., dccc)"
  type        = string
}
variable "name" {
  description = "Resource-specific name (e.g., vpc, lambda, s3-etl)"
  type        = string
}
variable "environment" {
  description = "Deployment environment (e.g., dev, uat, prod)"
  type        = string
}