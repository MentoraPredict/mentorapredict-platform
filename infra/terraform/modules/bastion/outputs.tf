output "instance_ids" {
  value = { for zone, instance in aws_instance.bastion : zone => instance.id }
}

output "security_group_id" {
  value = aws_security_group.bastion.id
}
