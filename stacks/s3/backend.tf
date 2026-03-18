terraform {
  backend "s3" {
    bucket         = "dccc-tfstate-bucket"
    key            = "terraform/user1/terraform.tfstate"
    region         = "us-gov-west-1"
  }
}
