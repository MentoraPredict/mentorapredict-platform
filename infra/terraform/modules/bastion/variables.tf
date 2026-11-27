variable "name" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "management_subnets" {
  description = "Management subnet IDs keyed by availability zone."
  type        = map(string)
  validation {
    condition     = length(var.management_subnets) > 0 && length(distinct(values(var.management_subnets))) == length(var.management_subnets)
    error_message = "Provide at least one distinct management subnet."
  }
}

variable "ami_id" {
  description = "AMI with the SSM agent installed for the selected region."
  type        = string
  validation {
    condition     = can(regex("^ami-[0-9a-f]+$", var.ami_id))
    error_message = "Provide a valid AMI ID."
  }
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "instance_profile_name" {
  description = "Existing instance profile with Systems Manager permissions."
  type        = string
  validation {
    condition     = length(trimspace(var.instance_profile_name)) > 0
    error_message = "Provide an existing instance profile name."
  }
}
