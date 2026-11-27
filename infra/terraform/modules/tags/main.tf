terraform {
  required_version = ">= 1.10.0, < 2.0.0"
}

locals {
  region_short      = { "us-east-1" = "use1", "us-west-2" = "usw2" }
  region_role       = { "us-east-1" = "primaria", "us-west-2" = "recuperacion" }
  environment_short = { produccion = "prod", staging = "stg", desarrollo = "dev" }

  # Mandatory tags of DOC-A-INF-06 section 6.2.
  base = {
    proyecto         = "mentorapredict"
    entorno          = var.environment
    "region-rol"     = local.region_role[var.region]
    propietario      = var.owner
    "centro-costo"   = var.cost_center
    capa             = var.layer
    modulo           = var.module
    servicio         = var.service
    "tenant-tier"    = var.tenant_tier
    confidencialidad = var.confidentiality
    "gestionado-por" = "terraform"
    repositorio      = "mentorapredict-services"
    version          = var.infrastructure_version
  }

  # Institutions with dedicated isolation also carry the institution tag.
  tags = var.tenant_tier == "dedicado" ? merge(local.base, { institucion = var.institution }) : local.base
}
