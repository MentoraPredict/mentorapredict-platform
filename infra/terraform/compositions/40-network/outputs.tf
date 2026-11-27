output "vpc_id" {
  value = module.red.vpc_id
}
output "subredes" {
  value = module.red.subredes
}
output "endpoint_client_security_group_id" {
  value = module.red.endpoint_client_security_group_id
}
output "subnet_ids_by_tier" {
  value = module.red.subnet_ids_by_tier
}
output "route_table_ids" {
  value = module.red.route_table_ids
}
output "gateway_endpoint_ids" {
  value = module.red.gateway_endpoint_ids
}
