variable "region" {
  description = "AWS region of the Module A QA infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket" {
  description = "S3 bucket that stores the Module C Terraform state."
  type        = string
}

variable "state_key" {
  description = "S3 key of the 80-modulo-c composition state."
  type        = string
  default     = "80-modulo-c/terraform.tfstate"
}

variable "state_region" {
  description = "Region of the S3 state bucket."
  type        = string
  default     = "us-east-1"
}

variable "master_dbname" {
  description = "Database used by the PostgreSQL provider to create Module C databases."
  type        = string
  default     = "postgres"
}
