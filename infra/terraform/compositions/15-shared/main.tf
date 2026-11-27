provider "aws" {
  region = var.region
  default_tags {
    tags = module.tags.tags
  }
}

module "tags" {
  source                 = "../../modules/tags"
  environment            = "compartida"
  region                 = var.region
  owner                  = var.owner
  cost_center            = var.cost_center
  layer                  = "compartida"
  module                 = "plataforma"
  confidentiality        = var.confidentiality
  infrastructure_version = var.infrastructure_version
}

module "ecr" {
  source                  = "../../modules/ecr"
  repositories            = var.repositories
  replication_destination = var.replication_destination
}
