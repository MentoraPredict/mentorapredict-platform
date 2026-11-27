module "tags" {
  source                 = "../../modules/tags"
  environment            = var.entorno
  region                 = var.region
  owner                  = var.propietario
  cost_center            = var.centro_costo
  layer                  = "bootstrap"
  module                 = var.modulo
  confidentiality        = var.confidencialidad
  infrastructure_version = var.version_infra
}

provider "aws" {
  region = var.region

  default_tags {
    tags = module.tags.tags
  }
}

data "aws_iam_policy_document" "bucket" {
  statement {
    sid    = "DenyInsecureTransport"
    effect = "Deny"
    actions = [
      "s3:*"
    ]
    resources = [
      aws_s3_bucket.estado.arn,
      "${aws_s3_bucket.estado.arn}/*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_kms_key" "estado" {
  description             = "Encryption key for Terraform state"
  enable_key_rotation     = true
  deletion_window_in_days = 30

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_kms_alias" "estado" {
  name          = var.alias_clave
  target_key_id = aws_kms_key.estado.key_id
}

resource "aws_s3_bucket" "estado" {
  bucket = var.nombre_bucket

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_public_access_block" "estado" {
  bucket                  = aws_s3_bucket.estado.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "estado" {
  bucket = aws_s3_bucket.estado.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "estado" {
  bucket = aws_s3_bucket.estado.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.estado.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_policy" "estado" {
  bucket = aws_s3_bucket.estado.id
  policy = data.aws_iam_policy_document.bucket.json
}
