output "rds_address" {
  description = "Writer endpoint of the shared Module C PostgreSQL instance."
  value       = module.data.rds_address
}

output "rds_port" {
  description = "Port of the shared Module C PostgreSQL instance."
  value       = module.data.rds_port
}

output "rds_master_secret_arn" {
  description = "ARN of the RDS-managed master user secret."
  value       = module.data.rds_master_secret_arn
}

output "valkey_endpoint" {
  description = "Primary endpoint of the Module C Valkey replication group."
  value       = module.data.valkey_endpoint
}

output "valkey_port" {
  description = "TLS port of the Module C Valkey replication group."
  value       = module.data.valkey_port
}

output "valkey_secret_arn" {
  description = "ARN of the secret that stores the Valkey auth token."
  value       = module.data.valkey_secret_arn
}

output "ssm_prefix" {
  description = "SSM Parameter Store prefix for Module C endpoints."
  value       = var.ssm_prefix
}

output "service_role_arns" {
  description = "IRSA role ARNs keyed by service code."
  value       = { for code, service in module.service : code => service.role_arn }
}

output "service_secret_arns" {
  description = "Runtime database secret ARNs keyed by service code."
  value       = { for code, service in module.service : code => service.db_secret_arn }
}

output "service_owner_secret_arns" {
  description = "Migration database secret ARNs keyed by service code."
  value       = { for code, service in module.service : code => service.db_owner_secret_arn }
}

output "service_kms_key_arns" {
  description = "Service KMS key ARNs keyed by service code."
  value       = { for code, service in module.service : code => service.kms_key_arn }
}

output "service_accounts" {
  description = "Kubernetes service accounts keyed by service code."
  value       = { for code, service in module.service : code => service.service_account_name }
}

output "replicas_min" {
  description = "Minimum replicas keyed by service code."
  value       = { for code, service in module.service : code => service.replicas_min }
}

output "topics" {
  description = "Kafka topic settings keyed by topic name."
  value       = module.catalog.topics
}

output "topic_names" {
  description = "Kafka topic names owned by Module C."
  value       = sort(keys(module.catalog.topics))
}
