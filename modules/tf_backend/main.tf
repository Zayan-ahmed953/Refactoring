provider "aws" {
  region = var.region
}
resource "aws_s3_bucket" "tf_state" {
  bucket        = local.resource_name
  force_destroy = true
  tags          = local.default_tags
}
resource "aws_dynamodb_table" "tf_locks" {
  name         = "${local.resource_name}-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = local.default_tags
}