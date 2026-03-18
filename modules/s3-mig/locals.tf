locals {
  # Construct standardized resource name
  # Format: organization-team-resource name-environment (e.g., tomss-sp-lambda-dev)

  bucket_name = "${var.organization}-${var.team}-${var.env}-${var.purpose}"
  
# Default tags applied to resources

  default_tags = {
    "dea:application:name"  = "dccc"
    "dea:cost-allocation:businessunit" =  "drt"
    "dea:operations:team"  =  "diversion"
    "dea:application:owner"  = "andrea mcclain"
    "dea:automation:backup"  = false
    "dea:automation:environment"  = "pre-prod"
    ManagedBy   = "Terraform"
    Environment = var.env
    Team        = var.team
  }
  
  all_tags = local.default_tags

}