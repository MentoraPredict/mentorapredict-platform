variable "databases" {
  description = "Module C databases keyed by service code."
  type = map(object({
    name               = string
    runtime_role       = string
    owner_role         = string
    runtime_secret_arn = string
    owner_secret_arn   = string
    extensions         = list(string)
  }))
  validation {
    condition = alltrue([
      for code, database in var.databases :
      can(regex("^[A-Z]{3}$", code)) &&
      can(regex("^[a-z][a-z0-9_]*$", database.name)) &&
      can(regex("^[a-z][a-z0-9_]*$", database.runtime_role)) &&
      can(regex("^[a-z][a-z0-9_]*$", database.owner_role))
    ])
    error_message = "Use three-letter service codes and snake_case database and role names."
  }
}
