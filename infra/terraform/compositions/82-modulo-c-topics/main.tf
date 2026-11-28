terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.7"
    }
  }
  backend "s3" {}
}

provider "kafka" {
  bootstrap_servers = [var.kafka_bootstrap_brokers]
  tls_enabled       = true
  sasl_mechanism    = "aws-iam"
  sasl_aws_region   = var.region
  sasl_aws_role_arn = var.kafka_admin_role_arn
}

module "catalog" {
  source = "../../modules/modulo-c-catalog"
}

module "topics" {
  source = "../../modules/modulo-c-topics"

  topics = module.catalog.topics
}
