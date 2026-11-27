locals {
  subredes = merge([
    for i, zona in var.zonas : {
      for tipo, cidr in {
        publica    = cidrsubnet(var.cidr_vpc, 8, i)
        endpoints  = cidrsubnet(var.cidr_vpc, 10, 12 + i)
        gestion    = cidrsubnet(var.cidr_vpc, 10, 16 + i)
        directorio = cidrsubnet(var.cidr_vpc, 10, 20 + i)
        aplicacion = cidrsubnet(var.cidr_vpc, 4, 1 + i)
        datos      = cidrsubnet(var.cidr_vpc, 8, 64 + i)
      } : "${tipo}-${i}" => { tipo = tipo, indice = i, zona = zona, cidr = cidr }
    }
  ]...)

  # Short names used in resource names (DOC-A-INF-06 section 6.3).
  nombre_capa = { publica = "publica", aplicacion = "app", datos = "datos", endpoints = "endpoints", gestion = "gestion", directorio = "directorio" }
  letra_zona  = [for zona in var.zonas : substr(zona, -1, 1)]
}

resource "aws_vpc" "principal" {
  cidr_block           = var.cidr_vpc
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = { Name = "${var.nombre}-vpc" }
}

resource "aws_subnet" "red" {
  for_each          = local.subredes
  vpc_id            = aws_vpc.principal.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.zona
  tags              = { Name = "${var.nombre}-sn-${local.nombre_capa[each.value.tipo]}-${local.letra_zona[each.value.indice]}" }
}

resource "aws_internet_gateway" "red" {
  vpc_id = aws_vpc.principal.id
  tags   = { Name = "${var.nombre}-igw" }
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = { Name = "${var.nombre}-nat-${local.letra_zona[0]}-eip" }
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_nat_gateway" "red" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.red["publica-0"].id
  depends_on    = [aws_internet_gateway.red]
  tags          = { Name = "${var.nombre}-nat-${local.letra_zona[0]}" }
}

resource "aws_route_table" "publica" {
  vpc_id = aws_vpc.principal.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.red.id
  }
  tags = { Name = "${var.nombre}-rt-publica" }
}

resource "aws_route_table" "privada" {
  for_each = toset(["aplicacion", "datos", "endpoints", "gestion", "directorio"])
  vpc_id   = aws_vpc.principal.id
  tags     = { Name = "${var.nombre}-rt-${local.nombre_capa[each.key]}" }
}

resource "aws_route" "salida_nat" {
  for_each               = toset(["aplicacion", "gestion", "directorio"])
  route_table_id         = aws_route_table.privada[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.red.id
}

resource "aws_route_table_association" "subred" {
  for_each       = local.subredes
  subnet_id      = aws_subnet.red[each.key].id
  route_table_id = each.value.tipo == "publica" ? aws_route_table.publica.id : aws_route_table.privada[each.value.tipo].id
}

resource "aws_vpc_endpoint" "gateway" {
  for_each          = toset(["s3", "dynamodb"])
  vpc_id            = aws_vpc.principal.id
  service_name      = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.privada["aplicacion"].id, aws_route_table.privada["datos"].id]
  tags              = { Name = "${var.nombre}-endpoint-${each.key}" }
}

# Attach this additional group to approved workloads that need private AWS APIs.
# Service owners remain responsible for the rest of their security group rules.
resource "aws_security_group" "endpoint_client" {
  name        = "${var.nombre}-endpoint-client"
  description = "Allows approved workloads to reach VPC interface endpoints"
  vpc_id      = aws_vpc.principal.id
  tags        = { Name = "${var.nombre}-endpoint-client" }
}

resource "aws_security_group" "endpoints" {
  name        = "${var.nombre}-endpoints"
  description = "Allows HTTPS from the endpoint client security group"
  vpc_id      = aws_vpc.principal.id
  tags        = { Name = "${var.nombre}-endpoints" }
}

resource "aws_vpc_security_group_ingress_rule" "endpoint_https" {
  security_group_id            = aws_security_group.endpoints.id
  referenced_security_group_id = aws_security_group.endpoint_client.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

resource "aws_vpc_security_group_egress_rule" "client_https" {
  security_group_id            = aws_security_group.endpoint_client.id
  referenced_security_group_id = aws_security_group.endpoints.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

# Gateway endpoints use the AWS-managed prefix lists rather than the
# interface endpoint security group. Attach this group only to workloads
# that need access; IAM and endpoint policies still govern permitted actions.
resource "aws_vpc_security_group_egress_rule" "gateway_https" {
  for_each          = aws_vpc_endpoint.gateway
  security_group_id = aws_security_group.endpoint_client.id
  prefix_list_id    = each.value.prefix_list_id
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

locals {
  interface_services = toset([
    "ecr.api", "ecr.dkr", "sts", "kms", "secretsmanager", "logs",
    "ssm", "ssmmessages", "ec2messages", "eks-auth", "storagegateway"
  ])
}

resource "aws_vpc_endpoint" "interface" {
  for_each            = var.enable_interface_endpoints ? local.interface_services : toset([])
  vpc_id              = aws_vpc.principal.id
  service_name        = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [for i in range(length(var.zonas)) : aws_subnet.red["endpoints-${i}"].id]
  security_group_ids  = [aws_security_group.endpoints.id]
  tags                = { Name = "${var.nombre}-endpoint-${replace(each.key, ".", "-")}" }
}
