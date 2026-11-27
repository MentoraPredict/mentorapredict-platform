variable "environment" {
  description = "Environment of the resources."
  type        = string
  validation {
    condition     = contains(["produccion", "staging", "desarrollo", "sandbox", "compartida"], var.environment)
    error_message = "environment must be produccion, staging, desarrollo, sandbox or compartida."
  }
}

variable "region" {
  description = "AWS region. It determines the region-rol tag."
  type        = string
  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.region)
    error_message = "Use us-east-1 (primary) or us-west-2 (recovery)."
  }
}

variable "owner" {
  description = "Team or person that owns the resources, for example plataforma."
  type        = string
  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner must not be empty."
  }
}

variable "cost_center" {
  description = "Budget code used to allocate costs."
  type        = string
  validation {
    condition     = length(trimspace(var.cost_center)) > 0
    error_message = "cost_center must not be empty."
  }
}

variable "layer" {
  description = "Terraform layer, for example bootstrap, red, datos, plataforma or borde."
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z-]*$", var.layer))
    error_message = "layer must use lowercase letters and hyphens."
  }
}

variable "module" {
  description = "Owning module."
  type        = string
  validation {
    condition     = contains(["a", "b", "c", "plataforma"], var.module)
    error_message = "module must be a, b, c or plataforma."
  }
}

variable "service" {
  description = "Service code, such as GRD, or plataforma."
  type        = string
  default     = "plataforma"
  validation {
    condition     = var.service == "plataforma" || can(regex("^[A-Z]{3}$", var.service))
    error_message = "service must be plataforma or a three-letter uppercase service code."
  }
}

variable "tenant_tier" {
  description = "Isolation model used for cost allocation."
  type        = string
  default     = "n/a"
  validation {
    condition     = contains(["pool", "dedicado", "n/a"], var.tenant_tier)
    error_message = "tenant_tier must be pool, dedicado or n/a."
  }
}

variable "institution" {
  description = "Institution identifier. Required when tenant_tier is dedicado."
  type        = string
  default     = null
  validation {
    condition     = var.tenant_tier != "dedicado" || try(length(trimspace(var.institution)) > 0, false)
    error_message = "institution is required when tenant_tier is dedicado."
  }
}

variable "confidentiality" {
  description = "Data classification of the resources."
  type        = string
  validation {
    condition     = contains(["datos-personales", "interno", "publico"], var.confidentiality)
    error_message = "confidentiality must be datos-personales, interno or publico."
  }
}

variable "infrastructure_version" {
  description = "Repository version tag that applies the resources."
  type        = string
  validation {
    condition     = length(trimspace(var.infrastructure_version)) > 0
    error_message = "infrastructure_version must not be empty."
  }
}
