variable "region" {
  type    = string
  default = "us-east-1"
}
variable "owner" {
  type = string
}
variable "cost_center" {
  type = string
}
variable "confidentiality" {
  type = string
}
variable "infrastructure_version" {
  type = string
}
variable "repositories" {
  type = map(object({
    consumer_account_ids = set(string)
  }))
}
variable "replication_destination" {
  type = object({
    region      = string
    registry_id = string
  })
  default = null
}
