mock_provider "aws" {
  mock_data "aws_secretsmanager_secret_version" {
    defaults = {
      secret_string = "{\"password\":\"test-password\"}"
    }
  }
}

mock_provider "postgresql" {}

variables {
  databases = {
    AUL = {
      name               = "aula_db"
      runtime_role       = "svc_aul"
      owner_role         = "svc_aul_owner"
      runtime_secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:mentora-qa-aul-db"
      owner_secret_arn   = "arn:aws:secretsmanager:us-east-1:123456789012:secret:mentora-qa-aul-db-owner"
      extensions         = ["pgcrypto"]
    }
    GRD = {
      name               = "calificaciones_db"
      runtime_role       = "svc_grd"
      owner_role         = "svc_grd_owner"
      runtime_secret_arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret:mentora-qa-grd-db"
      owner_secret_arn   = "arn:aws:secretsmanager:us-east-1:123456789012:secret:mentora-qa-grd-db-owner"
      extensions         = ["pgcrypto"]
    }
  }
}

run "plans_databases" {
  command = plan

  assert {
    condition     = length(output.database_names) == 2
    error_message = "The module must create one database per service."
  }

  assert {
    condition     = output.runtime_roles["AUL"] == "svc_aul"
    error_message = "The runtime role must not own the database."
  }
}
