terraform {
  backend "s3" {
    bucket         = "dccc-tfstate-bucket"
    key            = "terraform/user_glue/terraform.tfstate"
    region         = "us-gov-west-1"
  }
}