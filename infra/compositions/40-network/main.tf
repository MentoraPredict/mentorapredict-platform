module "tags" {
  source                 = "../../modules/tags"
  environment            = var.entorno
  region                 = var.region
  owner                  = var.propietario
  cost_center            = var.centro_costo
  layer                  = "red"
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

module "red" {
  source   = "../../modules/network"
  cidr_vpc = var.cidr_vpc
  zonas    = var.zonas
  nombre   = module.tags.name_prefix
  region   = var.region
}
