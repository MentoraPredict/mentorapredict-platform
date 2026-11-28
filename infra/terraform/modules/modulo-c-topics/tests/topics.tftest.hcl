mock_provider "kafka" {}

variables {
  topics = {
    "mp.aul.aula.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 7776000000
      cleanup_policy     = "delete"
    }
    "mp.rsk.alerta-conductual.v1" = {
      partitions         = 6
      replication_factor = 3
      retention_ms       = 7776000000
      cleanup_policy     = "delete"
    }
  }
}

run "plans_topics" {
  command = plan

  assert {
    condition     = length(output.topic_names) == 2
    error_message = "The module must create one topic per catalogue entry."
  }
}
