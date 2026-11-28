package ec.edu.mentora.testing;

import static org.assertj.core.api.Assertions.assertThat;

import ec.edu.mentora.platform.outbox.OutboxMessage;
import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class InMemoryOutboxStoreTest {

  @Test
  void returnsOnlyThePendingMessagesUpToTheLimit() {
    InMemoryOutboxStore store = new InMemoryOutboxStore();
    OutboxMessage first = message("first");
    OutboxMessage second = message("second");
    store.append(first);
    store.append(second);

    assertThat(store.pending(1)).containsExactly(first);
  }

  @Test
  void hidesPublishedMessages() {
    InMemoryOutboxStore store = new InMemoryOutboxStore();
    OutboxMessage message = message("first");
    store.append(message);

    store.markPublished(message.id());

    assertThat(store.pending(10)).isEmpty();
  }

  private static OutboxMessage message(String topic) {
    return new OutboxMessage(UUID.randomUUID(), topic, "{}", Instant.parse("2026-11-27T10:15:30Z"));
  }
}
