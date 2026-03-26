# terraform {
#   backend "s3" {
#     bucket         = "devops-tf-state-sp"
#     key            = "prod/terraform.tfstate"
#     region         = "us-east-2"
#     dynamodb_table = "terraform-state-locking"
#     encrypt        = true
#   }
# }

terraform {
  backend "s3" {
    bucket         = "dccc-tfstate-bucket"
    key            = "terraform/prod/terraform.tfstate"
    region         = "us-east-1"
  }
}