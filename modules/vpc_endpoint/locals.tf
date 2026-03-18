locals {
  # Standard naming convention for VPC Endpoint name
  vpce_name = var.vpce_name != "" ? var.vpce_name : "${var.organization}-${var.team}-${var.resource_type}-${var.purpose}-${var.env}"

  # Default tags applied to all VPC Endpoint
  default_tags = {
    "dea:application:name"  = "dccc"
    "dea:cost-allocation:businessunit" =  "drt"
    "dea:operations:team"  =  "diversion"
    "dea:application:owner"  = "andrea mcclain"
    "dea:automation:environment"  = "pre-prod"
    ManagedBy   = "Terraform"
    Environment = var.env
    Team        = var.team
    Name       =  local.vpce_name
  }

  all_tags = local.default_tags
}