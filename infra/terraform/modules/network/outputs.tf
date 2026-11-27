output "vpc_id" {
  value = aws_vpc.principal.id
}
output "subredes" {
  value = { for nombre, subred in aws_subnet.red : nombre => subred.id }
}
output "endpoint_client_security_group_id" {
  description = "Attach to approved workloads for HTTPS access to the configured AWS endpoints."
  value       = aws_security_group.endpoint_client.id
}
output "interface_endpoint_ids" {
  description = "Interface endpoint IDs by AWS service."
  value       = { for service, endpoint in aws_vpc_endpoint.interface : service => endpoint.id }
}
output "subnet_ids_by_tier" {
  description = "Subnet IDs grouped by network tier for downstream compositions."
  value = {
    for tier in ["publica", "aplicacion", "datos", "endpoints", "gestion", "directorio"] :
    tier => [for index in range(length(var.zonas)) : aws_subnet.red["${tier}-${index}"].id]
  }
}
output "route_table_ids" {
  description = "Route table IDs by tier for integration and verification."
  value       = merge({ publica = aws_route_table.publica.id }, { for tier, table in aws_route_table.privada : tier => table.id })
}
output "gateway_endpoint_ids" {
  description = "S3 and DynamoDB gateway endpoint IDs."
  value       = { for service, endpoint in aws_vpc_endpoint.gateway : service => endpoint.id }
}
