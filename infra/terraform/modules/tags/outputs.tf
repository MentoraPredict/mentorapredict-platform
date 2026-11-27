output "tags" {
  description = "Tags to apply through the default_tags block of the provider."
  value       = local.tags
}

output "name_prefix" {
  description = "Resource name prefix mp-<environment>-<short region>. Null for sandbox and compartida, which have no documented abbreviation."
  value       = contains(keys(local.environment_short), var.environment) ? "mp-${local.environment_short[var.environment]}-${local.region_short[var.region]}" : null
}
