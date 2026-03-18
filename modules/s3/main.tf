locals {
  workspace_suffix        = terraform.workspace == "default" ? "" : "-${terraform.workspace}"
  standard_bucket_name    = "${var.standard_bucket_name}${local.workspace_suffix}"
  glacier_bucket_name     = "${var.glacier_bucket_name}${local.workspace_suffix}"
}

resource "aws_s3_bucket" "standard" {
  bucket = local.standard_bucket_name

  tags                 = var.tags
  object_lock_enabled  = false
}

resource "aws_s3_bucket" "glacier" {
  bucket = local.glacier_bucket_name

  tags                 = var.tags
  object_lock_enabled  = false
}

