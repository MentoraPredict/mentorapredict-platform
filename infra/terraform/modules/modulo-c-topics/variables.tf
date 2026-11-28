variable "topics" {
  description = "Kafka topics keyed by topic name."
  type = map(object({
    partitions         = number
    replication_factor = number
    retention_ms       = number
    cleanup_policy     = string
  }))
  validation {
    condition = alltrue([
      for name, topic in var.topics :
      can(regex("^mp\\.[a-z]+\\.[a-z0-9-]+\\.v[0-9]+$", name)) &&
      topic.partitions > 0 &&
      topic.replication_factor > 0 &&
      topic.retention_ms > 0 &&
      contains(["delete", "compact", "compact,delete"], topic.cleanup_policy)
    ])
    error_message = "Use mp.<svc>.<aggregate>.v<N> topic names, positive partition and replication counts, and a supported cleanup policy."
  }
}
