terraform {
  required_version = ">= 1.10.0, < 2.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {}
}

module "tags" {
  source = "../../modules/tags"

  environment            = var.environment
  region                 = var.region
  owner                  = var.owner
  cost_center            = var.cost_center
  layer                  = var.layer
  module                 = var.module
  confidentiality        = var.confidentiality
  infrastructure_version = var.infrastructure_version
}

provider "aws" {
  region = var.region

  default_tags {
    tags = module.tags.tags
  }
}

module "catalog" {
  source = "../../modules/modulo-c-catalog"
}

module "data" {
  source = "../../modules/modulo-c-data"

  name_prefix               = module.tags.name_prefix
  environment               = var.environment
  region                    = var.region
  vpc_id                    = var.vpc_id
  data_subnet_ids           = var.data_subnet_ids
  client_security_group_ids = var.client_security_group_ids
  services = {
    for code, service in module.catalog.services : code => {
      name           = service.name
      level          = service.level
      database_name  = service.database_name
      valkey_enabled = service.valkey_enabled
      topics         = service.topics
    }
  }

  kms_deletion_window_in_days     = var.kms_deletion_window_in_days
  rds_instance_class              = var.rds_instance_class
  rds_allocated_storage           = var.rds_allocated_storage
  rds_max_allocated_storage       = var.rds_max_allocated_storage
  rds_backup_retention_period     = var.rds_backup_retention_period
  rds_multi_az                    = var.rds_multi_az
  rds_deletion_protection         = var.rds_deletion_protection
  rds_skip_final_snapshot         = var.rds_skip_final_snapshot
  rds_master_username             = var.rds_master_username
  rds_ca_cert_identifier          = var.rds_ca_cert_identifier
  valkey_node_type                = var.valkey_node_type
  valkey_num_cache_clusters       = var.valkey_num_cache_clusters
  valkey_engine_version           = var.valkey_engine_version
  valkey_snapshot_retention_limit = var.valkey_snapshot_retention_limit
  kafka_bootstrap_brokers         = var.kafka_bootstrap_brokers
  ssm_prefix                      = var.ssm_prefix
  tags                            = module.tags.tags
}

module "service" {
  for_each = module.catalog.services

  source = "../../modules/modulo-c-service"

  name_prefix                 = module.tags.name_prefix
  environment                 = var.environment
  region                      = var.region
  account_id                  = var.account_id
  service                     = each.key
  service_name                = each.value.name
  level                       = each.value.level
  database_name               = each.value.database_name
  topics                      = each.value.topics
  valkey_enabled              = each.value.valkey_enabled
  namespace                   = var.namespace
  service_account_name        = "${var.role_name_prefix}-${lower(each.key)}"
  role_name_prefix            = var.role_name_prefix
  oidc_provider_arn           = var.oidc_provider_arn
  oidc_issuer                 = var.oidc_issuer
  db_host                     = module.data.rds_address
  db_port                     = module.data.rds_port
  valkey_endpoint             = each.value.valkey_enabled ? module.data.valkey_endpoint : ""
  valkey_secret_arn           = each.value.valkey_enabled ? module.data.valkey_secret_arn : ""
  kafka_bootstrap_brokers     = var.kafka_bootstrap_brokers
  kafka_cluster_arn           = var.kafka_cluster_arn
  kafka_secret_arn            = var.kafka_secret_arn
  s3_bucket_arns              = each.value.s3_enabled ? var.content_bucket_arns : []
  s3_kms_key_arns             = each.value.s3_enabled ? var.content_kms_key_arns : []
  data_kms_key_arn            = module.data.kms_key_arn
  kms_deletion_window_in_days = var.kms_deletion_window_in_days
  rotation_lambda_arn         = var.rotation_lambda_arn
  ssm_prefix                  = var.ssm_prefix
  tags                        = module.tags.tags
}
