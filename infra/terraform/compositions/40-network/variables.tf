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
variable "enable_interface_endpoints" {
  description = "Create interface endpoints for services such as ECR and SSM; they incur charges."
  type        = bool
  default     = false
}
variable "zonas" {
  type = list(string)
  validation {
    condition     = length(var.zonas) == 2 && length(distinct(var.zonas)) == 2 && alltrue([for zone in var.zonas : startswith(zone, var.region)])
    error_message = "Provide two distinct availability zones in the selected region."
  }
}
variable "entorno" {
  description = "Environment of the resources."
  type        = string
  default     = "staging"
  validation {
    condition     = var.entorno == "staging"
    error_message = "This composition is limited to staging; production requires one NAT per zone."
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
