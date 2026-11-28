output "rds_address" {
  description = "Writer endpoint of the shared Module C PostgreSQL instance."
  value       = aws_db_instance.postgres.address
}

output "rds_port" {
  description = "Port of the shared Module C PostgreSQL instance."
  value       = aws_db_instance.postgres.port
}

output "rds_master_secret_arn" {
  description = "ARN of the RDS-managed master user secret."
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}

output "rds_security_group_id" {
  description = "Security group that protects the shared PostgreSQL instance."
  value       = aws_security_group.postgres.id
}

output "valkey_endpoint" {
  description = "Primary endpoint of the Module C Valkey replication group."
  value       = aws_elasticache_replication_group.valkey.primary_endpoint_address
}

output "valkey_port" {
  description = "TLS port of the Module C Valkey replication group."
  value       = aws_elasticache_replication_group.valkey.port
}

output "valkey_secret_arn" {
  description = "ARN of the secret that stores the Valkey auth token."
  value       = aws_secretsmanager_secret.valkey.arn
}

output "valkey_security_group_id" {
  description = "Security group that protects the Module C Valkey cache."
  value       = aws_security_group.valkey.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key shared by the Module C data resources."
  value       = aws_kms_key.data.arn
}

output "ssm_prefix" {
  description = "SSM Parameter Store prefix for Module C endpoints."
  value       = var.ssm_prefix
}
