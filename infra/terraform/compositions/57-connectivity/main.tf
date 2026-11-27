module "tags" {
  source                 = "../../modules/tags"
  environment            = var.environment
  region                 = var.region
  owner                  = var.owner
  cost_center            = var.cost_center
  layer                  = "gestion"
  module                 = var.module
  confidentiality        = var.confidentiality
  infrastructure_version = var.infrastructure_version
}

provider "aws" {
  region = var.region
  default_tags {
    tags = module.tags.tags
  }
}

module "bastion" {
  source                = "../../modules/bastion"
  name                  = module.tags.name_prefix
  vpc_id                = var.vpc_id
  management_subnets    = var.management_subnets
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  instance_profile_name = var.instance_profile_name
}
