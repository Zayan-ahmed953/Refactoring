locals {
  # Construct standardized resource name
  # Format: company-team-name-environment (e.g., sp-dccc-lambda-dev)

  resource_name = "${var.company}-${var.team}-${var.name}-${var.environment}"
  
  # Default tags to apply to all resources in this module
  default_tags = {
    Name        = local.resource_name
    Company     = var.company
    Team        = var.team
    Environment = var.environment
  }
}
