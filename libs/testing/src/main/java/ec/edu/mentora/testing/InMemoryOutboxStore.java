package ec.edu.mentora.testing;

import ec.edu.mentora.platform.outbox.OutboxMessage;
import ec.edu.mentora.platform.outbox.OutboxStore;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.UUID;

public final class InMemoryOutboxStore implements OutboxStore {

  private final List<OutboxMessage> messages = new ArrayList<>();
  private final Set<UUID> published = new HashSet<>();

  @Override
  public synchronized void append(OutboxMessage message) {
    messages.add(message);
  }

  @Override
  public synchronized OutboxMessage[] pending(int limit) {
    List<OutboxMessage> pending = new ArrayList<>();
    for (OutboxMessage message : messages) {
      if (!published.contains(message.id()) && pending.size() < limit) {
        pending.add(message);
      }
    }
    return pending.toArray(OutboxMessage[]::new);
  }

  @Override
  public synchronized void markPublished(UUID id) {
    published.add(id);
  }
}
