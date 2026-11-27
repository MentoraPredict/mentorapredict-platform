variable "cidr_vpc" {
  type = string
  validation {
    condition     = can(cidrnetmask(var.cidr_vpc)) && try(tonumber(split("/", var.cidr_vpc)[1]), 0) == 16
    error_message = "The network template requires an IPv4 /16 CIDR."
  }
}
variable "zonas" {
  type = list(string)
  validation {
    condition     = contains([2, 3], length(var.zonas)) && length(distinct(var.zonas)) == length(var.zonas)
    error_message = "Provide two or three distinct availability zones."
  }
}
variable "nombre" {
  type = string
}
variable "region" {
  type = string
}
variable "enable_interface_endpoints" {
  description = "Create the interface endpoints in addition to the S3 and DynamoDB gateway endpoints."
  type        = bool
  default     = false
}
