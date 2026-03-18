locals {
  # Standard naming convention for Glue Job name
  glue_job_name = "${var.organization}-${var.team}-${var.purpose}-${var.env}"
  # Default tags applied to all Glue resources
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