package ec.edu.mentora.platform.outbox;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class OutboxMessageTest {

  @Test
  void rejectsABlankTopic() {
    UUID id = UUID.randomUUID();
    Instant occurredAt = Instant.parse("2026-11-27T10:15:30Z");

    assertThatThrownBy(() -> new OutboxMessage(id, " ", "{}", occurredAt))
        .isInstanceOf(IllegalArgumentException.class);
  }

  @Test
  @SuppressWarnings("NullAway")
  void rejectsMissingValues() {
    Instant occurredAt = Instant.parse("2026-11-27T10:15:30Z");

    assertThatThrownBy(() -> new OutboxMessage(null, "mp.aul.aula.v1", "{}", occurredAt))
        .isInstanceOf(NullPointerException.class);
  }
}
