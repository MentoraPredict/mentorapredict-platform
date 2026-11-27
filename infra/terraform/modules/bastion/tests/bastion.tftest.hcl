mock_provider "aws" {}

variables {
  name                  = "mp-staging"
  vpc_id                = "vpc-0123456789abcdef0"
  management_subnets    = { us-east-1a = "subnet-0123456789abcdef0" }
  ami_id                = "ami-0123456789abcdef0"
  instance_profile_name = "LabInstanceProfile"
}

override_data {
  target = data.aws_subnet.management["us-east-1a"]
  values = {
    vpc_id            = "vpc-0123456789abcdef0"
    availability_zone = "us-east-1a"
  }
}

run "private_bastion" {
  command = apply
  assert {
    condition     = !aws_instance.bastion["us-east-1a"].associate_public_ip_address && aws_instance.bastion["us-east-1a"].metadata_options[0].http_tokens == "required" && aws_instance.bastion["us-east-1a"].root_block_device[0].encrypted
    error_message = "The bastion must use private addressing, IMDSv2 and encrypted storage."
  }
  assert {
    condition     = length(aws_security_group.bastion.ingress) == 0 && aws_vpc_security_group_egress_rule.https.from_port == 443 && aws_vpc_security_group_egress_rule.https.to_port == 443
    error_message = "The bastion must have no inbound rules and only the configured HTTPS egress."
  }
}

run "reject_wrong_vpc" {
  command = plan
  override_data {
    target = data.aws_subnet.management["us-east-1a"]
    values = {
      vpc_id            = "vpc-11111111111111111"
      availability_zone = "us-east-1a"
    }
  }
  expect_failures = [aws_instance.bastion]
}

run "reject_duplicate_subnets" {
  command = plan
  variables {
    management_subnets = { us-east-1a = "subnet-0123456789abcdef0", us-east-1b = "subnet-0123456789abcdef0" }
  }
  expect_failures = [var.management_subnets]
}
