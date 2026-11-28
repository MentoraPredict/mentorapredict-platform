variable "name_prefix" {
  description = "Resource name prefix produced by the shared tags module."
  type        = string
}

variable "environment" {
  description = "Environment of the resources."
  type        = string
  validation {
    condition     = contains(["staging", "produccion"], var.environment)
    error_message = "environment must be staging or produccion."
  }
}

variable "region" {
  description = "AWS region of the Module A QA infrastructure."
  type        = string
}

variable "vpc_id" {
  description = "VPC created by the Module A network composition."
  type        = string
}

variable "data_subnet_ids" {
  description = "Data subnet IDs created by the Module A network composition."
  type        = list(string)
  validation {
    condition     = length(var.data_subnet_ids) >= 2
    error_message = "Provide at least two data subnets in different availability zones."
  }
}

variable "client_security_group_ids" {
  description = "Security groups of the Module A EKS workloads allowed to reach PostgreSQL and Valkey."
  type        = list(string)
  validation {
    condition     = length(var.client_security_group_ids) > 0
    error_message = "Provide at least one workload security group."
  }
}

variable "services" {
  description = "Module C service catalogue keyed by service code."
  type = map(object({
    name           = string
    level          = number
    database_name  = string
    valkey_enabled = bool
    topics         = list(string)
  }))
  validation {
    condition = alltrue([
      for code, service in var.services :
      can(regex("^[A-Z]{3}$", code)) &&
      contains([1, 2], service.level) &&
      can(regex("^[a-z][a-z0-9_]*$", service.database_name)) &&
      alltrue([for topic in service.topics : can(regex("^mp\\.[a-z]+\\.[a-z0-9-]+\\.v[0-9]+$", topic))])
    ])
    error_message = "Use three-letter service codes, level 1 or 2, snake_case database names and mp.<svc>.<aggregate>.v<N> topics."
  }
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period before deleting Module C KMS keys."
  type        = number
  default     = 30
}

variable "rds_instance_class" {
  description = "Instance class of the shared QA PostgreSQL instance."
  type        = string
  default     = "db.t4g.medium"
}

variable "rds_allocated_storage" {
  description = "Initial storage of the shared QA PostgreSQL instance in GiB."
  type        = number
  default     = 100
}

variable "rds_max_allocated_storage" {
  description = "Maximum storage of the shared QA PostgreSQL instance in GiB."
  type        = number
  default     = 200
}

variable "rds_backup_retention_period" {
  description = "Backup retention in days."
  type        = number
  default     = 7
}

variable "rds_multi_az" {
  description = "Create a standby instance in a second availability zone."
  type        = bool
  default     = false
}

variable "rds_deletion_protection" {
  description = "Protect the database from accidental deletion."
  type        = bool
  default     = false
}

variable "rds_skip_final_snapshot" {
  description = "Skip the final snapshot when the QA database is destroyed."
  type        = bool
  default     = true
}

variable "rds_master_username" {
  description = "Master username of the shared PostgreSQL instance."
  type        = string
  default     = "mentora_admin"
}

variable "rds_ca_cert_identifier" {
  description = "RDS CA certificate used by clients with TLS."
  type        = string
  default     = "rds-ca-rsa2048-g1"
}

variable "valkey_node_type" {
  description = "ElastiCache node type for the Module C Valkey cache."
  type        = string
  default     = "cache.t4g.micro"
}

variable "valkey_num_cache_clusters" {
  description = "Number of Valkey nodes. QA uses one; production uses at least two."
  type        = number
  default     = 1
}

variable "valkey_engine_version" {
  description = "ElastiCache Valkey engine version."
  type        = string
  default     = "7.2"
}

variable "valkey_snapshot_retention_limit" {
  description = "Number of days to retain Valkey snapshots."
  type        = number
  default     = 0
}

variable "kafka_bootstrap_brokers" {
  description = "TLS bootstrap brokers of the Module A MSK cluster. Empty until MPC-161 is applied."
  type        = string
  default     = ""
}

variable "ssm_prefix" {
  description = "SSM Parameter Store prefix for Module C endpoints."
  type        = string
  default     = "/mentora/staging/modulo-c"
}

variable "tags" {
  description = "Common tags produced by the shared tags module."
  type        = map(string)
}
