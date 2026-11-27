variable "region" {
  type = string
  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.region)
    error_message = "Use us-east-1 (primary) or us-west-2 (recovery)."
  }
}
variable "cidr_vpc" {
  type    = string
  default = "10.20.0.0/16"
}
variable "zonas" {
  type = list(string)
  validation {
    condition     = length(var.zonas) == (var.entorno == "produccion" ? 3 : 2) && length(distinct(var.zonas)) == length(var.zonas)
    error_message = "Provide distinct availability zones: three for produccion, two for other environments."
  }
}
variable "entorno" {
  description = "Environment of the resources."
  type        = string
  default     = "staging"
  validation {
    condition     = contains(["produccion", "staging", "desarrollo"], var.entorno)
    error_message = "Allowed values: produccion, staging, desarrollo."
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
