output "database_names" {
  description = "Created database names keyed by service code."
  value       = module.databases.database_names
}

output "runtime_roles" {
  description = "Runtime roles keyed by service code."
  value       = module.databases.runtime_roles
}

output "owner_roles" {
  description = "Migration roles keyed by service code."
  value       = module.databases.owner_roles
}
