mock_provider "aws" {}

run "private_immutable_repository" {
  command = plan
  variables {
    repositories = {
      "example-service" = { consumer_account_ids = ["123456789012"] }
    }
  }

  assert {
    condition     = aws_ecr_repository.service["example-service"].image_tag_mutability == "IMMUTABLE"
    error_message = "Image tags must be immutable."
  }

  assert {
    condition     = length(aws_ecr_replication_configuration.registry) == 0
    error_message = "Registry-wide replication must remain disabled unless explicitly configured."
  }

  assert {
    condition     = length(aws_ecr_repository_policy.pull) == 1
    error_message = "A pull policy is required for the declared consumer."
  }
}

run "reject_invalid_account" {
  command = plan
  variables {
    repositories = {
      "example-service" = { consumer_account_ids = ["invalid"] }
    }
  }
  expect_failures = [var.repositories]
}
