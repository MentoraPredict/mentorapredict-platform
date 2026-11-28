output "database_names" {
  description = "Created database names keyed by service code."
  value       = { for code, database in postgresql_database.service : code => database.name }
}

output "runtime_roles" {
  description = "Runtime roles keyed by service code."
  value       = { for code, role in postgresql_role.runtime : code => role.name }
}

output "owner_roles" {
  description = "Migration roles keyed by service code."
  value       = { for code, role in postgresql_role.owner : code => role.name }
}
