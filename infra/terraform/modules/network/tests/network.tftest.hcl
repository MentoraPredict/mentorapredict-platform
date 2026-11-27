mock_provider "aws" {}

variables {
  cidr_vpc                   = "10.20.0.0/16"
  zonas                      = ["us-east-1a", "us-east-1b"]
  nombre                     = "mp-stg-use1"
  region                     = "us-east-1"
  enable_interface_endpoints = true
}

run "gateway_only" {
  command = plan
  variables {
    enable_interface_endpoints = false
  }
  assert {
    condition     = length(aws_vpc_endpoint.gateway) == 2 && length(aws_vpc_endpoint.interface) == 0
    error_message = "The gateway-only option must not create interface endpoints."
  }
  assert {
    condition     = length(aws_vpc_security_group_egress_rule.gateway_https) == 2 && alltrue([for rule in aws_vpc_security_group_egress_rule.gateway_https : rule.ip_protocol == "tcp" && rule.from_port == 443 && rule.to_port == 443])
    error_message = "The endpoint client group must allow HTTPS to both gateway endpoint prefix lists."
  }
}

run "staging_network_layout" {
  command = plan

  assert {
    condition     = length(aws_subnet.red) == 12 && aws_subnet.red["publica-0"].cidr_block == "10.20.0.0/24" && aws_subnet.red["aplicacion-1"].cidr_block == "10.20.32.0/20" && aws_subnet.red["directorio-1"].cidr_block == "10.20.5.64/26"
    error_message = "Staging must use the documented subnet layout in two zones."
  }

  assert {
    condition     = !contains(keys(aws_route.salida_nat), "datos") && !contains(keys(aws_route.salida_nat), "endpoints")
    error_message = "Data and endpoint subnets must not have an internet route."
  }

  assert {
    condition     = length(aws_vpc_endpoint.gateway) == 2 && length(aws_vpc_endpoint.interface) == 11
    error_message = "The documented S3, DynamoDB and interface endpoints are required."
  }

  assert {
    condition     = alltrue([for endpoint in aws_vpc_endpoint.interface : endpoint.private_dns_enabled])
    error_message = "Interface endpoints must enable private DNS."
  }
}

run "reject_ipv6" {
  command = plan
  variables {
    cidr_vpc = "2001:db8::/16"
  }
  expect_failures = [var.cidr_vpc]
}

run "reject_duplicate_zones" {
  command = plan
  variables {
    zonas = ["us-east-1a", "us-east-1a"]
  }
  expect_failures = [var.zonas]
}
