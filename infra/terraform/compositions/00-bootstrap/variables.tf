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

variable "entorno" {
  description = "Environment of the resources."
  type        = string
  default     = "staging"
  validation {
    condition     = contains(["produccion", "staging", "desarrollo", "sandbox", "compartida"], var.entorno)
    error_message = "Allowed values: produccion, staging, desarrollo, sandbox, compartida."
  }
}

variable "propietario" {
  description = "Team or person that owns the resources."
  type        = string
}

variable "centro_costo" {
  description = "Budget code used to allocate costs."
  type        = string
}

variable "modulo" {
  description = "Owning module: a, b, c or plataforma."
  type        = string
}

variable "confidencialidad" {
  description = "Data classification: datos-personales, interno or publico."
  type        = string
}

variable "version_infra" {
  description = "Repository version tag that applies the resources."
  type        = string
}
