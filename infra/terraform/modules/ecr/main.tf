resource "aws_ecr_repository" "service" {
  for_each             = var.repositories
  name                 = each.key
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

resource "aws_ecr_repository_policy" "pull" {
  for_each = {
    for name, config in var.repositories : name => config
    if length(config.consumer_account_ids) > 0
  }

  repository = aws_ecr_repository.service[each.key].name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "AllowAuthorizedAccountsToPull"
      Effect    = "Allow"
      Principal = { AWS = [for id in sort(tolist(each.value.consumer_account_ids)) : "arn:aws:iam::${id}:root"] }
      Action    = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer", "ecr:BatchCheckLayerAvailability"]
    }]
  })
}

resource "aws_ecr_replication_configuration" "registry" {
  count = var.replication_destination == null ? 0 : 1

  replication_configuration {
    rule {
      destination {
        region      = var.replication_destination.region
        registry_id = var.replication_destination.registry_id
      }
    }
  }
}
