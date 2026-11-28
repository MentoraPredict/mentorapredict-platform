provider "aws" {
  region = var.region
}

data "terraform_remote_state" "modulo_c" {
  backend = "s3"

  config = {
    bucket = var.state_bucket
    key    = var.state_key
    region = var.state_region
  }
}

data "aws_secretsmanager_secret_version" "master" {
  secret_id = data.terraform_remote_state.modulo_c.outputs.rds_master_secret_arn
}

locals {
  master = jsondecode(data.aws_secretsmanager_secret_version.master.secret_string)
}

provider "postgresql" {
  host            = data.terraform_remote_state.modulo_c.outputs.rds_address
  port            = data.terraform_remote_state.modulo_c.outputs.rds_port
  username        = local.master["username"]
  password        = local.master["password"]
  database        = var.master_dbname
  sslmode         = "require"
  superuser       = false
  connect_timeout = 10
}

module "catalog" {
  source = "../../modules/modulo-c-catalog"
}

module "databases" {
  source = "../../modules/modulo-c-databases"

  databases = {
    for code, service in module.catalog.services : code => {
      name               = service.database_name
      runtime_role       = "svc_${lower(code)}"
      owner_role         = "svc_${lower(code)}_owner"
      runtime_secret_arn = data.terraform_remote_state.modulo_c.outputs.service_secret_arns[code]
      owner_secret_arn   = data.terraform_remote_state.modulo_c.outputs.service_owner_secret_arns[code]
      extensions         = service.extensions
    }
  }
}
