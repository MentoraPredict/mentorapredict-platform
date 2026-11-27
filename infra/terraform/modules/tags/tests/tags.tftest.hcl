variables {
  environment          = "staging"
  region           = "us-east-1"
  owner      = "plataforma"
  cost_center     = "valor-de-prueba"
  layer             = "red"
  module           = "a"
  confidentiality = "interno"
  infrastructure_version    = "prueba"
}

run "etiquetas_y_prefijo_de_staging" {
  command = plan

  assert {
    condition     = length(setsubtract(["proyecto", "entorno", "region-rol", "propietario", "centro-costo", "capa", "modulo", "servicio", "tenant-tier", "confidencialidad", "gestionado-por", "repositorio", "version"], keys(output.tags))) == 0
    error_message = "A mandatory tag is missing."
  }
  assert {
    condition     = output.tags["region-rol"] == "primaria" && output.name_prefix == "mp-stg-use1"
    error_message = "Wrong region role or name prefix."
  }
  assert {
    condition     = !contains(keys(output.tags), "institucion")
    error_message = "institucion only applies to dedicated tenants."
  }
}

run "recuperacion" {
  command = plan
  variables {
    environment = "produccion"
    region  = "us-west-2"
  }
  assert {
    condition     = output.tags["region-rol"] == "recuperacion" && output.name_prefix == "mp-prod-usw2"
    error_message = "Wrong recovery tags or prefix."
  }
}

run "sandbox_sin_prefijo" {
  command = plan
  variables {
    environment = "sandbox"
  }
  assert {
    condition     = output.name_prefix == null
    error_message = "sandbox has no documented abbreviation."
  }
}

run "dedicado_con_institucion" {
  command = plan
  variables {
    tenant_tier = "dedicado"
    institution = "institucion-de-prueba"
  }
  assert {
    condition     = output.tags["institucion"] == "institucion-de-prueba"
    error_message = "The institucion tag is missing."
  }
}

run "dedicado_sin_institucion" {
  command = plan
  variables {
    tenant_tier = "dedicado"
  }
  expect_failures = [var.institution]
}

run "valores_no_permitidos" {
  command = plan
  variables {
    environment          = "qa"
    module           = "d"
    confidentiality = "secreto"
    service         = "grading"
  }
  expect_failures = [var.environment, var.module, var.confidentiality, var.service]
}

run "region_no_permitida" {
  command = plan
  variables {
    region = "sa-east-1"
  }
  expect_failures = [var.region]
}

run "obligatorias_vacias" {
  command = plan
  variables {
    owner   = " "
    cost_center  = ""
    infrastructure_version = ""
  }
  expect_failures = [var.owner, var.cost_center, var.infrastructure_version]
}
