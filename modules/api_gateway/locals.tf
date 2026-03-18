locals {
  # Standard naming convention for Api Gateway name
  api_name = var.api_name != "" ? var.api_name : "${var.organization}-${var.team}-${var.resource_type}-${var.purpose}-${var.env}"

  # Default tags applied to all Api Gateway
  default_tags = {
    "dea:application:name"  = "dccc"
    "dea:cost-allocation:businessunit" =  "drt"
    "dea:operations:team"  =  "diversion"
    "dea:application:owner"  = "andrea mcclain"
    "dea:automation:environment"  = "pre-prod"
    ManagedBy   = "Terraform"
    Environment = var.env
    Team        = var.team
  }

  all_tags = local.default_tags
}