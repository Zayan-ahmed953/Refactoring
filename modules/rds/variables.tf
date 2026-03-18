

variable "db_port" {
  description = "The port on which the database accepts connections."
  type        = number
  default     = 5432
}

variable "postgres_name" {
  description = "The name of the postgres database to create on the DB instance"
  type        = string
  default     = "tamr_rds_db"
}

variable "parameter_group_name" {
  description = "The name of the rds parameter group"
  type        = string
  default     = "dev-rds-postgres-pg"
}

variable "param_log_min_duration_statement" {
  description = "(ms) Sets the minimum execution time above which statements will be logged."
  type        = string
  default     = "-1"
}

variable "param_log_statement" {
  description = "Sets the type of statements logged. Valid values are none, ddl, mod, all"
  type        = string
  default     = "none"
}

variable "identifier_prefix" {
 # description = "Identifier  for the RDS instance"
  description = "Identifier prefix for the RDS instance"
  type        = string
 
}

variable "allocated_storage" {
  description = "Allocate storage"
  type        = number
  default     = 20
}

variable "max_allocated_storage" {
  description = "Max allocate storage"
  type        = number
  default     = 30
}

variable "storage_type" {
  description = "Storage type (e.g. gp2, io1)"
  type        = string
  default     = "gp2"
}

variable "instance_class" {
  description = "Instance class"
  type        = string
  default     =  "db.t4g.2xlarge"
}

variable "maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "sun:04:32-sun:05:02"
}

variable "backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:29-03:59"
}

variable "backup_retention_period" {
  description = "Backup retention period in days"
  type        = number
  default     = 14
}

variable "skip_final_snapshot" {
  description = "Skip final snapshot"
  type        = bool
  default     = true
}

variable "apply_immediately" {
  description = "Apply immediately, do not set this to true for production"
  type        = bool
  default     = false
}

variable "subnet_group_name" {
  description = "The name of the subnet group to add the RDS instance to"
  type        = string
  default = "dev_rds_subnet_group"
}

variable "rds_subnet_ids" {
  description = "VPC subnet IDs in subnet group"
  type        = list(string)
  //default =  ["subnet-05b13786e74641c93","subnet-07f93f53d3b76ea9c"]
}

variable "copy_tags_to_snapshot" {
  description = "Copy tags to snapshots"
  type        = bool
  default     = true
}

variable "additional_tags" {
  type        = map(string)
  description = "[DEPRECATED: Use `tags` instead] Additional tags to set on the RDS instance."
  default     = {
    RDS = "rds-backup"
  }
}

# variable "name" {
#   default = "rds"
# }

variable "tags" {
  type        = map(string)
  description = "A map of tags to add to all resources. Replaces `additional_tags`."
  default = {
    RDS = "rds-backup"
  }

}

# variable "security_group_ids" {
#   description = "List of security group IDs to associate"
#   type        = list(string)
# }

variable "engine_version" {
  description = "Version of RDS Postgres"
  type        = string
  default     = "12"
}

variable "parameter_group_family" {
  description = "The family of the DB parameter group"
  type        = string
  default     = "postgres12"
}

variable "auto_minor_version_upgrade" {
  default     = true
  type        = bool
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
}

variable "enabled_cloudwatch_logs_exports" {
  default     = true
  type        = bool
  description = "Indicates that postgresql logs will be configured to be sent automatically to Cloudwatch"
}

variable "multi_az" {
  default     = true
  type        = bool
  description = "Specifies if the RDS instance is multi-AZ."
}

variable "performance_insights_enabled" {
  default     = false
  type        = bool
  description = "Specifies whether Performance Insights are enabled."
}

variable "performance_insights_retention_period" {
  default     = 7
  type        = number
  description = "The amount of time in days to retain Performance Insights data. Either 7 (7 days) or 731 (2 years)."
}


#-----------------------------------------------------------------------------------------------------
# AWS Backup vault
#
variable "name" {
  description = "Name of the backup vault to create."
  type        = string
  default     = "rds"
}

variable "vault_kms_key_arn" {
  description = "The server-side encryption key that is used to protect your backups"
  type        = string
  default     = null
}

# Selection
variable "selection_resources" {
  description = "An array of strings that either contain Amazon Resource Names (ARNs) or match patterns of resources to assign to a backup plan"
  type        = list(any)
  default     = []
}

variable "selection_tag_type" {
  description = "An operation, such as StringEquals, that is applied to a key-value pair used to filter resources in a selection"
  type        = string
  default     = "STRINGEQUALS"
}

variable "selection_tag_key" {
  description = "The key in a key-value pair"
  type        = string
  default     = "Backup"
}

variable "selection_tag_value" {
  description = "The value in a key-value pair"
  type        = string
  default     = "true"
}

variable "db_engine" {
  description = "The DB engine "
  type        = string
  default     = "postgres"
}

variable "vpc_id" {
  description = "The DB engine "
  type        = string
  
}

variable "rds_sg" {
  description = "The DB security group "
  type        = string
  
}
