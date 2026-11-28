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

  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::123456789012:role/mentora-qa"
    }
  }

  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::123456789012:policy/mentora-qa"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}


variables {
  region                    = "us-east-1"
  account_id                = "123456789012"
  environment               = "staging"
  owner                     = "plataforma"
  cost_center               = "mpc-395"
  infrastructure_version    = "mpc-395-test"
  vpc_id                    = "vpc-0123456789abcdef0"
  data_subnet_ids           = ["subnet-0123456789abcdef0", "subnet-0123456789abcdef1"]
  client_security_group_ids = ["sg-0123456789abcdef0"]
  oidc_provider_arn         = "arn:aws:iam::123456789012:oidc-provider/oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE123"
  oidc_issuer               = "oidc.eks.us-east-1.amazonaws.com/id/EXAMPLE123"
  kafka_bootstrap_brokers   = "b-1.example.kafka.us-east-1.amazonaws.com:9098"
  kafka_cluster_arn         = "arn:aws:kafka:us-east-1:123456789012:cluster/mp-stg-use1-msk/11111111-2222-3333-4444-555555555555"
}

run "plans_module_c_data" {
  command = apply

  assert {
    condition     = output.rds_port == 5432
    error_message = "The PostgreSQL port must be 5432."
  }

  assert {
    condition     = output.valkey_endpoint == "valkey.modulo-c.internal"
    error_message = "Valkey must expose its primary endpoint."
  }
}

run "derives_replicas_from_level" {
  command = plan

  assert {
    condition     = output.replicas_min["AUL"] == 3
    error_message = "Level 1 services need three replicas."
  }

  assert {
    condition     = output.replicas_min["ANL"] == 2
    error_message = "Level 2 services need two replicas."
  }
}

run "creates_one_role_per_service" {
  command = plan

  assert {
    condition     = length(output.service_role_arns) == 10
    error_message = "Module C must create ten IRSA roles."
  }

  assert {
    condition     = output.service_accounts["CNT"] == "mentora-qa-cnt"
    error_message = "Each service must use its own service account."
  }
}

run "publishes_topics" {
  command = plan

  assert {
    condition     = length(output.topic_names) == 11
    error_message = "Module C owns eleven Kafka topics."
  }
}
