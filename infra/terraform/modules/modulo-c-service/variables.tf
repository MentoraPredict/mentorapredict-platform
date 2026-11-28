variable "name_prefix" {
  description = "Resource name prefix produced by the shared tags module."
  type        = string
}

variable "environment" {
  description = "Environment of the resources."
  type        = string
}

variable "region" {
  description = "AWS region of the Module A QA infrastructure."
  type        = string
}

variable "account_id" {
  description = "AWS account that owns the Module C resources."
  type        = string
}

variable "service" {
  description = "Three-letter Module C service code."
  type        = string
  validation {
    condition     = can(regex("^[A-Z]{3}$", var.service))
    error_message = "service must be a three-letter uppercase code."
  }
}

variable "service_name" {
  description = "Kubernetes and Kafka name of the service."
  type        = string
}

variable "level" {
  description = "Service level: 1 or 2."
  type        = number
  validation {
    condition     = contains([1, 2], var.level)
    error_message = "level must be 1 or 2."
  }
}

variable "database_name" {
  description = "PostgreSQL database owned by the service."
  type        = string
}

variable "topics" {
  description = "Kafka topics produced or consumed by the service."
  type        = list(string)
}

variable "valkey_enabled" {
  description = "Whether the service uses the Valkey cache."
  type        = bool
}

variable "namespace" {
  description = "Kubernetes namespace of the Module C services."
  type        = string
  default     = "modulo-c"
}

variable "service_account_name" {
  description = "Kubernetes service account bound to the IRSA role."
  type        = string
}

variable "role_name_prefix" {
  description = "Prefix of the IRSA role and database secret names."
  type        = string
  default     = "mentora-qa"
}

variable "oidc_provider_arn" {
  description = "ARN of the Module A EKS OIDC provider."
  type        = string
}

variable "oidc_issuer" {
  description = "Issuer URL of the Module A EKS OIDC provider without the https:// prefix."
  type        = string
}

variable "db_host" {
  description = "PostgreSQL writer endpoint."
  type        = string
}

variable "db_port" {
  description = "PostgreSQL port."
  type        = number
}

variable "db_sslmode" {
  description = "PostgreSQL SSL mode used by the service."
  type        = string
  default     = "require"
}

variable "valkey_endpoint" {
  description = "Valkey primary endpoint when the service uses the cache."
  type        = string
  default     = ""
}

variable "valkey_port" {
  description = "Valkey TLS port."
  type        = number
  default     = 6379
}

variable "valkey_secret_arn" {
  description = "ARN of the Valkey auth token secret when the service uses the cache."
  type        = string
  default     = ""
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
  description = "ARN of the Kafka client secret when the cluster uses SASL/SCRAM."
  type        = string
  default     = ""
}

variable "s3_bucket_arns" {
  description = "S3 buckets the service may read or write."
  type        = list(string)
  default     = []
}

variable "s3_kms_key_arns" {
  description = "KMS keys used by the S3 buckets."
  type        = list(string)
  default     = []
}

variable "data_kms_key_arn" {
  description = "ARN of the KMS key shared by PostgreSQL and Valkey."
  type        = string
}

variable "kms_deletion_window_in_days" {
  description = "Waiting period before deleting the service KMS key."
  type        = number
  default     = 30
}

variable "rotation_lambda_arn" {
  description = "Optional Secrets Manager rotation Lambda provided by the platform."
  type        = string
  default     = null
  nullable    = true
}

variable "ssm_prefix" {
  description = "SSM Parameter Store prefix for Module C endpoints."
  type        = string
}

variable "tags" {
  description = "Common tags produced by the shared tags module."
  type        = map(string)
}
