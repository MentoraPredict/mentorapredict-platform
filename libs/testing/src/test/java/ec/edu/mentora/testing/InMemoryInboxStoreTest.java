package ec.edu.mentora.testing;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.UUID;
import org.junit.jupiter.api.Test;

class InMemoryInboxStoreTest {

  @Test
  void processesAMessageOnlyOnce() {
    InMemoryInboxStore store = new InMemoryInboxStore();
    UUID messageId = UUID.randomUUID();

    assertThat(store.tryMarkProcessed(messageId)).isTrue();
    assertThat(store.tryMarkProcessed(messageId)).isFalse();
    assertThat(store.isProcessed(messageId)).isTrue();
  }
}
