terraform {
  backend "s3" {
    bucket         = "dccc-tfstate-bucket"
    key            = "terraform/terraform.tfstate"
    region         = "us-gov-west-1"
  }
}