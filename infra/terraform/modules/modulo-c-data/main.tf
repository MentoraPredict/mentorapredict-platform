locals {
  name        = var.name_prefix
  common_tags = merge(var.tags, { servicio = "compartido" })
  valkey_ha   = var.valkey_num_cache_clusters > 1
}

resource "aws_kms_key" "data" {
  description             = "${local.name}-modulo-c-data"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_in_days

  tags = local.common_tags
}

resource "aws_kms_alias" "data" {
  name          = "alias/${local.name}-modulo-c-data"
  target_key_id = aws_kms_key.data.key_id
}

resource "aws_db_subnet_group" "postgres" {
  name       = "${local.name}-modulo-c-postgres"
  subnet_ids = var.data_subnet_ids

  tags = local.common_tags
}

resource "aws_security_group" "postgres" {
  name        = "${local.name}-modulo-c-postgres"
  description = "PostgreSQL access for Module C workloads"
  vpc_id      = var.vpc_id

  tags = local.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "postgres" {
  for_each = toset(var.client_security_group_ids)

  security_group_id            = aws_security_group.postgres.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = 5432
  to_port                      = 5432
}

resource "aws_db_parameter_group" "postgres" {
  name   = "${local.name}-modulo-c-postgres16"
  family = "postgres16"

  parameter {
    name         = "rds.force_ssl"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_connections"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "log_disconnections"
    value        = "1"
    apply_method = "immediate"
  }

  parameter {
    name         = "password_encryption"
    value        = "scram-sha-256"
    apply_method = "pending-reboot"
  }

  tags = local.common_tags
}

resource "aws_db_instance" "postgres" {
  identifier = "${local.name}-modulo-c"

  engine         = "postgres"
  engine_version = "16"
  instance_class = var.rds_instance_class

  allocated_storage     = var.rds_allocated_storage
  max_allocated_storage = var.rds_max_allocated_storage
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.data.arn

  db_subnet_group_name   = aws_db_subnet_group.postgres.name
  vpc_security_group_ids = [aws_security_group.postgres.id]
  parameter_group_name   = aws_db_parameter_group.postgres.name
  publicly_accessible    = false

  username                      = var.rds_master_username
  manage_master_user_password   = true
  master_user_secret_kms_key_id = aws_kms_key.data.arn

  multi_az                = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention_period
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  deletion_protection       = var.rds_deletion_protection
  skip_final_snapshot       = var.rds_skip_final_snapshot
  final_snapshot_identifier = var.rds_skip_final_snapshot ? null : "${local.name}-modulo-c-final"
  copy_tags_to_snapshot     = true

  auto_minor_version_upgrade      = true
  apply_immediately               = false
  enabled_cloudwatch_logs_exports = ["postgresql"]
  ca_cert_identifier              = var.rds_ca_cert_identifier

  tags = local.common_tags
}

resource "aws_elasticache_subnet_group" "valkey" {
  name       = "${local.name}-modulo-c-valkey"
  subnet_ids = var.data_subnet_ids

  tags = local.common_tags
}

resource "aws_security_group" "valkey" {
  name        = "${local.name}-modulo-c-valkey"
  description = "Valkey access for Module C workloads"
  vpc_id      = var.vpc_id

  tags = local.common_tags
}

resource "aws_vpc_security_group_ingress_rule" "valkey" {
  for_each = toset(var.client_security_group_ids)

  security_group_id            = aws_security_group.valkey.id
  referenced_security_group_id = each.value
  ip_protocol                  = "tcp"
  from_port                    = 6379
  to_port                      = 6379
}

resource "random_password" "valkey" {
  length  = 40
  special = false
}

resource "aws_elasticache_replication_group" "valkey" {
  replication_group_id = "${local.name}-modulo-c-valkey"
  description          = "Module C Valkey cache for AUL and CNT"

  engine         = "valkey"
  engine_version = var.valkey_engine_version
  node_type      = var.valkey_node_type

  num_cache_clusters         = var.valkey_num_cache_clusters
  automatic_failover_enabled = local.valkey_ha
  multi_az_enabled           = local.valkey_ha

  at_rest_encryption_enabled = true
  kms_key_id                 = aws_kms_key.data.arn
  transit_encryption_enabled = true
  auth_token                 = random_password.valkey.result

  subnet_group_name        = aws_elasticache_subnet_group.valkey.name
  security_group_ids       = [aws_security_group.valkey.id]
  snapshot_retention_limit = var.valkey_snapshot_retention_limit
  maintenance_window       = "sun:05:00-sun:06:00"
  apply_immediately        = false

  tags = local.common_tags
}

resource "aws_secretsmanager_secret" "valkey" {
  name                    = "${local.name}-modulo-c-valkey"
  description             = "Valkey credentials for Module C AUL and CNT services"
  kms_key_id              = aws_kms_key.data.arn
  recovery_window_in_days = 7

  tags = local.common_tags
}

resource "aws_secretsmanager_secret_version" "valkey" {
  secret_id = aws_secretsmanager_secret.valkey.id
  secret_string = jsonencode({
    auth_token = random_password.valkey.result
    host       = aws_elasticache_replication_group.valkey.primary_endpoint_address
    port       = 6379
    tls        = true
  })
}

resource "aws_ssm_parameter" "rds_endpoint" {
  name  = "${var.ssm_prefix}/rds/endpoint"
  type  = "String"
  value = aws_db_instance.postgres.address

  tags = local.common_tags
}

resource "aws_ssm_parameter" "rds_port" {
  name  = "${var.ssm_prefix}/rds/port"
  type  = "String"
  value = "5432"

  tags = local.common_tags
}

resource "aws_ssm_parameter" "rds_master_secret_arn" {
  name  = "${var.ssm_prefix}/rds/master_secret_arn"
  type  = "String"
  value = aws_db_instance.postgres.master_user_secret[0].secret_arn

  tags = local.common_tags
}

resource "aws_ssm_parameter" "rds_ca_cert_identifier" {
  name  = "${var.ssm_prefix}/rds/ca_cert_identifier"
  type  = "String"
  value = var.rds_ca_cert_identifier

  tags = local.common_tags
}

resource "aws_ssm_parameter" "valkey_endpoint" {
  name  = "${var.ssm_prefix}/valkey/endpoint"
  type  = "String"
  value = aws_elasticache_replication_group.valkey.primary_endpoint_address

  tags = local.common_tags
}

resource "aws_ssm_parameter" "valkey_port" {
  name  = "${var.ssm_prefix}/valkey/port"
  type  = "String"
  value = "6379"

  tags = local.common_tags
}

resource "aws_ssm_parameter" "valkey_secret_arn" {
  name  = "${var.ssm_prefix}/valkey/secret_arn"
  type  = "String"
  value = aws_secretsmanager_secret.valkey.arn

  tags = local.common_tags
}

resource "aws_ssm_parameter" "kafka_bootstrap_brokers" {
  count = var.kafka_bootstrap_brokers == "" ? 0 : 1

  name  = "${var.ssm_prefix}/kafka/bootstrap_brokers"
  type  = "String"
  value = var.kafka_bootstrap_brokers

  tags = local.common_tags
}

resource "aws_ssm_parameter" "data_kms_key_arn" {
  name  = "${var.ssm_prefix}/kms/data_key_arn"
  type  = "String"
  value = aws_kms_key.data.arn

  tags = local.common_tags
}
