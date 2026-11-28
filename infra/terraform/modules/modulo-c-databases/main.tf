data "aws_secretsmanager_secret_version" "runtime" {
  for_each = var.databases

  secret_id = each.value.runtime_secret_arn
}

data "aws_secretsmanager_secret_version" "owner" {
  for_each = var.databases

  secret_id = each.value.owner_secret_arn
}

locals {
  runtime_passwords = {
    for code, database in var.databases : code => jsondecode(data.aws_secretsmanager_secret_version.runtime[code].secret_string)["password"]
  }
  owner_passwords = {
    for code, database in var.databases : code => jsondecode(data.aws_secretsmanager_secret_version.owner[code].secret_string)["password"]
  }
}

resource "postgresql_role" "owner" {
  for_each = var.databases

  name     = each.value.owner_role
  login    = true
  password = local.owner_passwords[each.key]

  inherit                   = true
  create_role               = false
  create_database           = false
  replication               = false
  superuser                 = false
  bypass_row_level_security = false
}

resource "postgresql_role" "runtime" {
  for_each = var.databases

  name     = each.value.runtime_role
  login    = true
  password = local.runtime_passwords[each.key]

  inherit                   = true
  create_role               = false
  create_database           = false
  replication               = false
  superuser                 = false
  bypass_row_level_security = false
}

resource "postgresql_database" "service" {
  for_each = var.databases

  name     = each.value.name
  owner    = postgresql_role.owner[each.key].name
  template = "template0"
  encoding = "UTF8"

  lc_collate        = "en_US.UTF-8"
  lc_ctype          = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true

  depends_on = [
    postgresql_role.owner,
    postgresql_role.runtime
  ]
}

resource "postgresql_grant" "database_runtime" {
  for_each = var.databases

  database    = postgresql_database.service[each.key].name
  role        = postgresql_role.runtime[each.key].name
  object_type = "database"
  privileges  = ["CONNECT", "TEMPORARY"]
}

resource "postgresql_grant" "schema_owner" {
  for_each = var.databases

  database    = postgresql_database.service[each.key].name
  role        = postgresql_role.owner[each.key].name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
}

resource "postgresql_grant" "schema_runtime" {
  for_each = var.databases

  database    = postgresql_database.service[each.key].name
  role        = postgresql_role.runtime[each.key].name
  schema      = "public"
  object_type = "schema"
  privileges  = ["USAGE"]
}

resource "postgresql_default_privileges" "tables_runtime" {
  for_each = var.databases

  database    = postgresql_database.service[each.key].name
  role        = postgresql_role.runtime[each.key].name
  owner       = postgresql_role.owner[each.key].name
  schema      = "public"
  object_type = "table"
  privileges  = ["SELECT", "INSERT", "UPDATE", "DELETE"]
}

resource "postgresql_default_privileges" "sequences_runtime" {
  for_each = var.databases

  database    = postgresql_database.service[each.key].name
  role        = postgresql_role.runtime[each.key].name
  owner       = postgresql_role.owner[each.key].name
  schema      = "public"
  object_type = "sequence"
  privileges  = ["USAGE", "SELECT", "UPDATE"]
}

resource "postgresql_extension" "pgcrypto" {
  for_each = {
    for code, database in var.databases : code => database
    if contains(database.extensions, "pgcrypto")
  }

  database = postgresql_database.service[each.key].name
  name     = "pgcrypto"
  schema   = "public"
}
