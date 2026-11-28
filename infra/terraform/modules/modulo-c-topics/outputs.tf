output "topic_names" {
  description = "Created topic names."
  value       = sort(keys(kafka_topic.this))
}
