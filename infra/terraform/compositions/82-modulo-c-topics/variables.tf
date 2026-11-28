variable "region" {
  description = "AWS region of the Module A MSK cluster."
  type        = string
  default     = "us-east-1"
}

variable "kafka_bootstrap_brokers" {
  description = "IAM bootstrap brokers of the Module A MSK cluster."
  type        = string
}

variable "kafka_admin_role_arn" {
  description = "Optional IAM role assumed by Terraform to manage MSK topics. Null uses the runner credentials."
  type        = string
  default     = null
  nullable    = true
}
