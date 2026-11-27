variable "region" {
  type = string
}
variable "environment" {
  type    = string
  default = "staging"
}
variable "owner" {
  type = string
}
variable "cost_center" {
  type = string
}
variable "module" {
  type = string
}
variable "confidentiality" {
  type = string
}
variable "infrastructure_version" {
  type = string
}
variable "vpc_id" {
  type = string
}
variable "management_subnets" {
  description = "Management subnet IDs keyed by availability zone."
  type        = map(string)
}
variable "ami_id" {
  description = "Regional AMI with the SSM agent installed."
  type        = string
}
variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "instance_profile_name" {
  description = "Existing instance profile with Systems Manager permissions."
  type        = string
}
