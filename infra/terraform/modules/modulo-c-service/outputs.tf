output "role_arn" {
  description = "ARN of the IRSA role assumed by the service."
  value       = aws_iam_role.service.arn
}

output "role_name" {
  description = "Name of the IRSA role assumed by the service."
  value       = aws_iam_role.service.name
}

output "policy_arn" {
  description = "ARN of the least-privilege IAM policy."
  value       = aws_iam_policy.service.arn
}

output "db_secret_arn" {
  description = "ARN of the service runtime database secret."
  value       = aws_secretsmanager_secret.db.arn
}

output "db_owner_secret_arn" {
  description = "ARN of the service migration database secret."
  value       = aws_secretsmanager_secret.db_owner.arn
}

output "kms_key_arn" {
  description = "ARN of the service KMS key."
  value       = aws_kms_key.service.arn
}

output "service_account_name" {
  description = "Kubernetes service account bound to the IRSA role."
  value       = local.service_account
}

output "replicas_min" {
  description = "Minimum replicas derived from the service level."
  value       = local.replicas_min
}
