terraform {
  backend "s3" {
    bucket = "dccc-prod-tfstate"
    key    = "terraform/terraform.tfstate"
    region = "us-gov-west-1"
  }
}
