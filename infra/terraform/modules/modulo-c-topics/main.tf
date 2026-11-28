resource "kafka_topic" "this" {
  for_each = var.topics

  name               = each.key
  partitions         = each.value.partitions
  replication_factor = each.value.replication_factor

  config = {
    "cleanup.policy"      = each.value.cleanup_policy
    "retention.ms"        = tostring(each.value.retention_ms)
    "min.insync.replicas" = "2"
    "compression.type"    = "producer"
  }
}
