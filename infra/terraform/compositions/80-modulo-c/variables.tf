variable "region" {
  description = "AWS region of the Module A QA infrastructure."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.region)
    error_message = "Use us-east-1 (primary) or us-west-2 (recovery)."
  }
}

variable "account_id" {
  description = "AWS account that owns the Module C resources."
  type        = string
  validation {
    condition     = can(regex("^[0-9]{12}$", var.account_id))
    error_message = "account_id must be a 12-digit AWS account ID."
  }
}

variable "environment" {
  description = "Environment of the resources. This composition is limited to QA (staging)."
  type        = string
  default     = "staging"
  validation {
    condition     = var.environment == "staging"
    error_message = "This composition is limited to QA (staging)."
  }
}

variable "owner" {
  description = "Team or person that owns the resources."
  type        = string
}

variable "cost_center" {
  description = "Budget code used to allocate costs."
  type        = string
}

variable "layer" {
  description = "Terraform layer of the composition."
  type        = string
  default     = "app-modulo-c"
}

variable "module" {
  description = "Owning module."
  type        = string
  default     = "c"
  validation {
    condition     = var.module == "c"
    error_message = "This composition only creates Module C resources."
  }
}

variable "confidentiality" {
  description = "Data classification of the resources."
  type        = string
  default     = "datos-personales"
  validation {
    condition     = contains(["datos-personales", "interno", "publico"], var.confidentiality)
    error_message = "confidentiality must be datos-personales, interno or publico."
  }
}

variable "infrastructure_version" {
  description = "Repository version tag that applies the resources."
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

variable "oidc_provider_arn" {
  description = "ARN of the Module A EKS OIDC provider."
  type        = string
}

variable "oidc_issuer" {
  description = "Issuer URL of the Module A EKS OIDC provider without the https:// prefix."
  type        = string
  validation {
    condition     = can(regex("^oidc\\.eks\\.[a-z0-9-]+\\.amazonaws\\.com/id/[A-Za-z0-9]+$", var.oidc_issuer))
    error_message = "Provide the EKS OIDC issuer without the https:// prefix."
  }
}

variable "kafka_bootstrap_brokers" {
  description = "TLS bootstrap brokers of the Module A MSK cluster."
  type        = string
  default     = ""
}

variable "kafka_cluster_arn" {
  description = "ARN of the Module A MSK cluster."
  type        = string
  default     = ""
}

variable "kafka_secret_arn" {
  description = "ARN of the Kafka client secret when the Module A cluster uses SASL/SCRAM."
  type        = string
  default     = ""
}

variable "content_bucket_arns" {
  description = "S3 buckets used by CNT, ASG, ANL and RPT."
  type        = list(string)
  default     = []
}

variable "content_kms_key_arns" {
  description = "KMS keys used by the content S3 buckets."
  type        = list(string)
  default     = []
}

variable "rotation_lambda_arn" {
  description = "Optional Secrets Manager rotation Lambda provided by the platform."
  type        = string
  default     = null
  nullable    = true
}

variable "role_name_prefix" {
  description = "Prefix of the IRSA role and database secret names."
  type        = string
  default     = "mentora-qa"
}

variable "namespace" {
  description = "Kubernetes namespace of the Module C services."
  type        = string
  default     = "modulo-c"
}

variable "ssm_prefix" {
  description = "SSM Parameter Store prefix for Module C endpoints."
  type        = string
  default     = "/mentora/staging/modulo-c"
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
