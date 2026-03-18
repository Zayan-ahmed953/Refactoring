terraform {
  backend "s3" {
    bucket         = "dccc-tfstate-bucket"
    key            = "terraform/user_lambda/terraform.tfstate"
    region         = "us-gov-west-1"
  }
}