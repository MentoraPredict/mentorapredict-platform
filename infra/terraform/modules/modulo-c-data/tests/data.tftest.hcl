mock_provider "aws" {
  mock_resource "aws_db_instance" {
    defaults = {
      address = "postgres.modulo-c.internal"
      port    = 5432
      master_user_secret = [
        {
          secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:rds-master"
        }
      ]
    }
  }

  mock_resource "aws_elasticache_replication_group" {
    defaults = {
      primary_endpoint_address = "valkey.modulo-c.internal"
      port                     = 6379
    }
  }

  mock_resource "aws_kms_key" {
    defaults = {
      arn = "arn:aws:kms:us-east-1:123456789012:key/modulo-c"
    }
  }

  mock_resource "aws_secretsmanager_secret" {
    defaults = {
      arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:modulo-c"
    }
  }
}


variables {
  name_prefix               = "mp-stg-use1"
  environment               = "staging"
  region                    = "us-east-1"
  vpc_id                    = "vpc-0123456789abcdef0"
  data_subnet_ids           = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  client_security_group_ids = ["sg-0123456789abcdef0"]
  services = {
    AUL = {
      name           = "classroom-service"
      level          = 1
      database_name  = "aula_db"
      valkey_enabled = true
      topics         = ["mp.aul.aula.v1"]
    }
    ANL = {
      name           = "analytics-service"
      level          = 2
      database_name  = "analitica_db"
      valkey_enabled = false
      topics         = ["mp.aul.aula.v1"]
    }
  }
  tags = {
    proyecto = "mentorapredict"
    entorno  = "staging"
    modulo   = "c"
  }
}

run "creates_shared_data" {
  command = apply

  assert {
    condition     = output.rds_port == 5432
    error_message = "The shared PostgreSQL instance must expose port 5432."
  }

  assert {
    condition     = output.valkey_endpoint == "valkey.modulo-c.internal"
    error_message = "The Valkey cache must expose its primary endpoint."
  }
}
