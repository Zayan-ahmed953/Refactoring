#------------------Common values values------------------#
aws_region     = "us-gov-west-1"
aws_access_key = ""
aws_secret_key = ""

#----------------Common Value------------------------------"
 env           = "dev"  # Change env as per enviromet Dev/test/Prod
 vpc_id        = "vpc-078259aa7268638fc" # Change VPC ID as per Account
 subnet_id     = "subnet-0cbb750677392eeca" # Change Subnet ID as per Account
 key_name      = "DEA-DCCC-DEV-KEY" # Create key pair as per Account

# # #------------------EC2 values----------------------#
 #ec2_ami       = "ami-074bd5ffc95f90624"  # update EC2 AMI ID
 ec2_ami       = "ami-0093f953ade2d1ae7"  # update EC2 AMI ID
 instance_type = "t3.medium"   # update EC2 size
 ec2_count     = 1
 ec2_name      = "test"  # update EC2 name
 sg_name       = "dccc-dev-sg"  # update sg name
# # #------------------s3 values----------------------#

standard_bucket_name = "dccc-dev-123"
glacier_bucket_name = "dccc-dev-glacier-123"


 ##--------------------RDS Values----------------------------#
db_engine     = "postgres"
rds_sg        = "dccc-rds-sg"
rds_subnet_ids =  ["subnet-0399addf9d5c7012f","subnet-0cbb750677392eeca"]
#identifier = "dccc-dev"
identifier_prefix = "dccc-dev"