#-------------------------------------EC2 Module--------------------------------#

module "ec2" {
  source        = "../../terraform-modules/ec2"
  count         = contains(var.deploy_modules, "ec2") ? 1 : 0
  subnet_id     = var.subnet_id
  ec2_ami       = var.ec2_ami
  instance_type = var.instance_type
  ec2_count     = var.ec2_count
  key_name      = var.key_name
  ec2_name      = var.ec2_name
  env           = var.env
  vpc_id        = var.vpc_id
  sg_name       = var.sg_name
}

#-------------------------------------S3 Module--------------------------------#
module "s3" {
  source               = "../../terraform-modules/s3"
  count                = contains(var.deploy_modules, "s3") ? 1 : 0
  standard_bucket_name = var.standard_bucket_name
  glacier_bucket_name  = var.glacier_bucket_name
  tags                 = var.tags
}

#-------------------------------------rds Module--------------------------------#
module "rds" {
  source            = "../../terraform-modules/rds"
  count             = contains(var.deploy_modules, "rds") ? 1 : 0
  db_engine         = var.db_engine
  vpc_id            = var.vpc_id
  rds_sg            = var.rds_sg
  rds_subnet_ids    = var.rds_subnet_ids
  #identifier = var.identifier
  identifier_prefix = var.identifier_prefix
}
