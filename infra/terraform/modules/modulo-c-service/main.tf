locals {
  oidc_issuer     = replace(var.oidc_issuer, "https://", "")
  service_lower   = lower(var.service)
  service_account = var.service_account_name != "" ? var.service_account_name : "${var.role_name_prefix}-${local.service_lower}"
  replicas_min    = var.level == 1 ? 3 : 2
  tags            = merge(var.tags, { servicio = var.service })
  kafka_topic_arns = [
    for topic in var.topics : "${replace(var.kafka_cluster_arn, ":cluster/", ":topic/")}/${topic}"
  ]
  kafka_group_arns = [
    "${replace(var.kafka_cluster_arn, ":cluster/", ":group/")}/modulo-c.${local.service_lower}.consumidor.*"
  ]
  kafka_transactional_id_arn = "${replace(var.kafka_cluster_arn, ":cluster/", ":transactional-id/")}/*"
}

resource "aws_kms_key" "service" {
  description             = "${var.name_prefix}-modulo-c-${local.service_lower}"
  enable_key_rotation     = true
  deletion_window_in_days = var.kms_deletion_window_in_days

  tags = local.tags
}

resource "aws_kms_alias" "service" {
  name          = "alias/${var.name_prefix}-modulo-c-${local.service_lower}"
  target_key_id = aws_kms_key.service.key_id
}

resource "random_password" "db" {
  length  = 40
  special = false
}

resource "random_password" "db_owner" {
  length  = 40
  special = false
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "${var.role_name_prefix}-${local.service_lower}-db"
  description             = "PostgreSQL runtime credentials for Module C ${var.service_name}"
  kms_key_id              = aws_kms_key.service.arn
  recovery_window_in_days = 7

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = "svc_${local.service_lower}"
    password = random_password.db.result
    host     = var.db_host
    port     = var.db_port
    dbname   = var.database_name
    sslmode  = var.db_sslmode
  })
}

resource "aws_secretsmanager_secret" "db_owner" {
  name                    = "${var.role_name_prefix}-${local.service_lower}-db-owner"
  description             = "PostgreSQL migration credentials for Module C ${var.service_name}"
  kms_key_id              = aws_kms_key.service.arn
  recovery_window_in_days = 7

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "db_owner" {
  secret_id = aws_secretsmanager_secret.db_owner.id
  secret_string = jsonencode({
    username = "svc_${local.service_lower}_owner"
    password = random_password.db_owner.result
    host     = var.db_host
    port     = var.db_port
    dbname   = var.database_name
    sslmode  = var.db_sslmode
  })
}

resource "aws_secretsmanager_secret_rotation" "db" {
  count = var.rotation_lambda_arn == null ? 0 : 1

  secret_id           = aws_secretsmanager_secret.db.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = 30
  }
}

resource "aws_secretsmanager_secret_rotation" "db_owner" {
  count = var.rotation_lambda_arn == null ? 0 : 1

  secret_id           = aws_secretsmanager_secret.db_owner.id
  rotation_lambda_arn = var.rotation_lambda_arn

  rotation_rules {
    automatically_after_days = 30
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowModuleCServiceAccount"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${local.service_account}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_issuer}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "service" {
  statement {
    sid       = "ReadOwnDatabaseSecret"
    effect    = "Allow"
    actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
    resources = [aws_secretsmanager_secret.db.arn, aws_secretsmanager_secret.db_owner.arn]
  }

  statement {
    sid       = "DecryptModuleCData"
    effect    = "Allow"
    actions   = ["kms:Decrypt", "kms:DescribeKey", "kms:GenerateDataKey"]
    resources = [aws_kms_key.service.arn, var.data_kms_key_arn]
  }

  statement {
    sid    = "ReadModuleCParameters"
    effect = "Allow"
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath"
    ]
    resources = [
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/services/${local.service_lower}",
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/services/${local.service_lower}/*",
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/rds",
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/rds/*",
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/valkey",
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/valkey/*",
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/kafka",
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/kafka/*",
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/kms",
      "arn:aws:ssm:${var.region}:${var.account_id}:parameter${var.ssm_prefix}/kms/*"
    ]
  }

  dynamic "statement" {
    for_each = var.valkey_enabled ? [1] : []

    content {
      sid       = "ReadValkeySecret"
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      resources = [var.valkey_secret_arn]
    }
  }

  dynamic "statement" {
    for_each = var.kafka_secret_arn == "" ? [] : [1]

    content {
      sid       = "ReadKafkaSecret"
      effect    = "Allow"
      actions   = ["secretsmanager:GetSecretValue", "secretsmanager:DescribeSecret"]
      resources = [var.kafka_secret_arn]
    }
  }

  dynamic "statement" {
    for_each = var.kafka_cluster_arn == "" || length(var.topics) == 0 ? [] : [1]

    content {
      sid       = "ConnectToKafkaCluster"
      effect    = "Allow"
      actions   = ["kafka-cluster:Connect", "kafka-cluster:DescribeCluster"]
      resources = [var.kafka_cluster_arn]
    }
  }

  dynamic "statement" {
    for_each = var.kafka_cluster_arn == "" || length(var.topics) == 0 ? [] : [1]

    content {
      sid    = "UseModuleCTopics"
      effect = "Allow"
      actions = [
        "kafka-cluster:DescribeTopic",
        "kafka-cluster:ReadData",
        "kafka-cluster:WriteData",
        "kafka-cluster:WriteDataIdempotently"
      ]
      resources = concat(local.kafka_topic_arns, [local.kafka_transactional_id_arn])
    }
  }

  dynamic "statement" {
    for_each = var.kafka_cluster_arn == "" || length(var.topics) == 0 ? [] : [1]

    content {
      sid    = "UseModuleCConsumerGroups"
      effect = "Allow"
      actions = [
        "kafka-cluster:DescribeGroup",
        "kafka-cluster:AlterGroup"
      ]
      resources = local.kafka_group_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.s3_bucket_arns) > 0 ? [1] : []

    content {
      sid       = "ListServiceBuckets"
      effect    = "Allow"
      actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
      resources = var.s3_bucket_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.s3_bucket_arns) > 0 ? [1] : []

    content {
      sid    = "ReadWriteServiceObjects"
      effect = "Allow"
      actions = [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:AbortMultipartUpload"
      ]
      resources = [for arn in var.s3_bucket_arns : "${arn}/*"]
    }
  }

  dynamic "statement" {
    for_each = length(var.s3_kms_key_arns) > 0 ? [1] : []

    content {
      sid       = "UseServiceBucketKeys"
      effect    = "Allow"
      actions   = ["kms:Decrypt", "kms:GenerateDataKey", "kms:DescribeKey"]
      resources = var.s3_kms_key_arns
    }
  }
}

resource "aws_iam_role" "service" {
  name               = "${var.role_name_prefix}-${local.service_lower}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = local.tags
}

resource "aws_iam_policy" "service" {
  name        = "${var.role_name_prefix}-${local.service_lower}"
  description = "Least-privilege access for Module C ${var.service_name}"
  policy      = data.aws_iam_policy_document.service.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "service" {
  role       = aws_iam_role.service.name
  policy_arn = aws_iam_policy.service.arn
}

resource "aws_ssm_parameter" "role_arn" {
  name  = "${var.ssm_prefix}/services/${local.service_lower}/role_arn"
  type  = "String"
  value = aws_iam_role.service.arn

  tags = local.tags
}

resource "aws_ssm_parameter" "db_secret_arn" {
  name  = "${var.ssm_prefix}/services/${local.service_lower}/db_secret_arn"
  type  = "String"
  value = aws_secretsmanager_secret.db.arn

  tags = local.tags
}

resource "aws_ssm_parameter" "db_owner_secret_arn" {
  name  = "${var.ssm_prefix}/services/${local.service_lower}/db_owner_secret_arn"
  type  = "String"
  value = aws_secretsmanager_secret.db_owner.arn

  tags = local.tags
}

resource "aws_ssm_parameter" "database_name" {
  name  = "${var.ssm_prefix}/services/${local.service_lower}/database_name"
  type  = "String"
  value = var.database_name

  tags = local.tags
}

resource "aws_ssm_parameter" "topics" {
  name  = "${var.ssm_prefix}/services/${local.service_lower}/topics"
  type  = "String"
  value = join(",", var.topics)

  tags = local.tags
}

resource "aws_ssm_parameter" "level" {
  name  = "${var.ssm_prefix}/services/${local.service_lower}/level"
  type  = "String"
  value = tostring(var.level)

  tags = local.tags
}

resource "aws_ssm_parameter" "replicas_min" {
  name  = "${var.ssm_prefix}/services/${local.service_lower}/replicas_min"
  type  = "String"
  value = tostring(local.replicas_min)

  tags = local.tags
}

resource "aws_ssm_parameter" "service_account" {
  name  = "${var.ssm_prefix}/services/${local.service_lower}/service_account"
  type  = "String"
  value = local.service_account

  tags = local.tags
}

resource "aws_ssm_parameter" "valkey_endpoint" {
  count = var.valkey_enabled ? 1 : 0

  name  = "${var.ssm_prefix}/services/${local.service_lower}/valkey_endpoint"
  type  = "String"
  value = var.valkey_endpoint

  tags = local.tags
}

resource "aws_ssm_parameter" "kafka_bootstrap_brokers" {
  count = var.kafka_bootstrap_brokers == "" ? 0 : 1

  name  = "${var.ssm_prefix}/services/${local.service_lower}/kafka_bootstrap_brokers"
  type  = "String"
  value = var.kafka_bootstrap_brokers

  tags = local.tags
}
