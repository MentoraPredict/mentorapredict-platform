output "bucket_estado" {
  description = "Name of the remote state bucket."
  value       = aws_s3_bucket.estado.id
}

output "clave_kms_arn" {
  description = "ARN of the key used to encrypt the Terraform state."
  value       = aws_kms_key.estado.arn
}
