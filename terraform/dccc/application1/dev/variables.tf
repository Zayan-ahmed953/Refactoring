#-------------------AWS common Variables-------------#
variable "aws_region" {}
//variable "token" {}
 variable "aws_access_key" {}
 variable "aws_secret_key" {}

variable "deploy_modules" {
  type = list(string)
  default = []
 
}
#----------------Common Varaibles for EC2----------------------#
variable "env" {}
variable "vpc_id" {}
variable "subnet_id" {}
variable "key_name" {}

# # #------------------EC2 varaibles-------------#
variable "ec2_ami" {}
variable "instance_type" {}
variable "ec2_count" {}
variable "ec2_name" {}
variable "sg_name" {}

#-----------------------S3 variables-------------------
variable "standard_bucket_name" {
  description = "Name of the standard S3 bucket"
  type        = string
}

variable "glacier_bucket_name" {
  description = "Name of the glacier S3 bucket"
  type        = string
}

variable "tags" {
  description = "Common tags for all buckets"
  type        = map(string)
  default     = {
    Name =  "sandboxtestbucket" 
    Env =  "dev"
  }

}
#--------------RDS Varaibles---------------------------------------

variable "db_engine" {
  description = "The DB engine "
  type        = string
  default     = "postgres"
}

variable "rds_sg" {
  description = "The DB security group "
  type        = string
  
}

variable "rds_subnet_ids" {
  description = "VPC subnet IDs in subnet group"
  type        = list(string)
}

variable "identifier_prefix" {
  description = "Identifier  for the RDS instance"
  type        = string
 
}
