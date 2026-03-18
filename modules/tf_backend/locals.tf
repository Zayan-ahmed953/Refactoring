locals {
  resource_name = "${var.company}-${var.team}-${var.name}-${var.environment}"
  default_tags = {
    Name        = local.resource_name
    Company     = var.company
    Team        = var.team
    Environment = var.environment
  }
}