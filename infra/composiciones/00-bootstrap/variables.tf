variable "region" {
  description = "AWS region for the state bucket and KMS key."
  type        = string
}

variable "nombre_bucket" {
  description = "Globally unique S3 bucket name for the target account and region."
  type        = string
}

variable "alias_clave" {
  description = "KMS alias for Terraform state, including the alias/ prefix."
  type        = string

  validation {
    condition     = startswith(var.alias_clave, "alias/")
    error_message = "The KMS alias must start with alias/."
  }
}

variable "etiquetas" {
  description = "Required resource tags agreed for the target account."
  type        = map(string)
}
