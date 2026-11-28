package ec.edu.mentora.platform.outbox;

import java.util.UUID;

public interface OutboxStore {

  void append(OutboxMessage message);

  OutboxMessage[] pending(int limit);

  void markPublished(UUID id);
}
