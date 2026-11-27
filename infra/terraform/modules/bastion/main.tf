resource "aws_security_group" "bastion" {
  name        = "${var.name}-bastion"
  description = "HTTPS egress for Systems Manager; no inbound access"
  vpc_id      = var.vpc_id
  tags        = { Name = "${var.name}-bastion" }
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.bastion.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port         = 443
  to_port           = 443
}

data "aws_subnet" "management" {
  for_each = var.management_subnets
  id       = each.value
}

resource "aws_instance" "bastion" {
  for_each                    = var.management_subnets
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = each.value
  iam_instance_profile        = var.instance_profile_name
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.bastion.id]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    encrypted   = true
    volume_type = "gp3"
  }

  lifecycle {
    precondition {
      condition     = data.aws_subnet.management[each.key].vpc_id == var.vpc_id && data.aws_subnet.management[each.key].availability_zone == each.key
      error_message = "Each subnet must belong to the selected VPC and match its availability zone key."
    }
  }

  tags = { Name = "${var.name}-bastion-${each.key}" }
}
