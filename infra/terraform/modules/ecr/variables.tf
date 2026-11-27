variable "repositories" {
  description = "Repository names and accounts allowed to pull images."
  type = map(object({
    consumer_account_ids = set(string)
  }))
  validation {
    condition = alltrue(flatten([
      for name, config in var.repositories : concat(
        [length(name) >= 2 && length(name) <= 256 && can(regex("^[a-z0-9]+([._-][a-z0-9]+)*(/[a-z0-9]+([._-][a-z0-9]+)*)*$", name))],
        [for id in config.consumer_account_ids : can(regex("^[0-9]{12}$", id))]
      )
    ]))
    error_message = "Use valid lowercase ECR repository names and 12-digit AWS account IDs."
  }
}

variable "replication_destination" {
  description = "Optional registry-wide replication destination; use only when this composition owns the registry replication configuration."
  type = object({
    region      = string
    registry_id = string
  })
  default  = null
  nullable = true
  validation {
    condition     = var.replication_destination == null ? true : can(regex("^[0-9]{12}$", var.replication_destination.registry_id)) && contains(["us-east-1", "us-west-2"], var.replication_destination.region)
    error_message = "Replication needs a supported region and a 12-digit destination registry ID."
  }
}
