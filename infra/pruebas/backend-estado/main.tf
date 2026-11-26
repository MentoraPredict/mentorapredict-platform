terraform {
  required_version = ">= 1.10.0, < 2.0.0"

  backend "s3" {}
}

variable "marca" {
  description = "Change this value to force a pending change during the lock test."
  type        = string
  default     = "inicial"
}

# terraform_data is built into Terraform: no provider download and no AWS resources.
resource "terraform_data" "prueba" {
  input = var.marca
}

output "marca" {
  description = "Value stored in the test state."
  value       = terraform_data.prueba.output
}
