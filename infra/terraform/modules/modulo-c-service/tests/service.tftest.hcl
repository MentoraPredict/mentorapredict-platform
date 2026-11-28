mock_provider "aws" {
  mock_resource "aws_kms_key" {
    defaults = {
      arn = "arn:aws:kms:us-east-1:123456789012:key/modulo-c-aul"
    }
  }

  mock_resource "aws_secretsmanager_secret" {
    defaults = {
      arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:mentora-qa-aul-db"
    }
  }

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/mentora-qa-aul"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/mentora-qa-aul"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}


variables {
  name_prefix             = "mp-stg-use1"
  environment             = "staging"
  region                  = "us-east-1"
  account_id              = "123456789012"
  service                 = "AUL"
  service_name            = "classroom-service"
  level                   = 1
  database_name           = "aula_db"
  topics                  = ["mp.aul.aula.v1", "mp.aul.entrega.v1"]
  valkey_enabled          = true
  service_account_name    = "mentora-qa-aul"
  oidc_provider_arn       = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE123"
  oidc_issuer             = "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE123"
  db_host                 = "postgres.modulo-c.internal"
  db_port                 = 5432
  valkey_endpoint         = "valkey.modulo-c.internal"
  valkey_secret_arn       = "arn:aws:secretsmanager:us-east-1:123456789012:secret:valkey"
  kafka_bootstrap_brokers = "b-1.example.kafka.us-east-1.amazonaws.com:9098"
  kafka_cluster_arn       = "arn:aws:kafka:us-east-1:123456789012:cluster/mp-stg-use1-msk/11111111-2222-3333-4444-555555555555"
  data_kms_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/modulo-c-data"
  ssm_prefix              = "/mentora/staging/modulo-c"
  tags = {
    proyecto = "mentorapredict"
    entorno  = "staging"
    modulo   = "c"
  }
}

run "plans_service_role" {
  command = plan

  assert {
    condition     = output.replicas_min == 3
    error_message = "A level 1 service needs three minimum replicas."
  }

  assert {
    condition     = output.service_account_name == "mentora-qa-aul"
    error_message = "The IRSA role must bind to the service account."
  }
}
