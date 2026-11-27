package ec.edu.mentora.platform.outbox;

import java.time.Instant;
import java.util.Objects;
import java.util.UUID;

public record OutboxMessage(UUID id, String topic, String payload, Instant occurredAt) {

  public OutboxMessage {
    Objects.requireNonNull(id, "id");
    Objects.requireNonNull(topic, "topic");
    Objects.requireNonNull(payload, "payload");
    Objects.requireNonNull(occurredAt, "occurredAt");
    if (topic.isBlank()) {
      throw new IllegalArgumentException("topic must not be blank");
    }
  }
}
