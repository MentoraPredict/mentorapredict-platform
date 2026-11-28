package ec.edu.mentora.testing;

import ec.edu.mentora.platform.inbox.InboxStore;
import java.util.HashSet;
import java.util.Set;
import java.util.UUID;

public final class InMemoryInboxStore implements InboxStore {

  private final Set<UUID> processed = new HashSet<>();

  @Override
  public synchronized boolean tryMarkProcessed(UUID messageId) {
    return processed.add(messageId);
  }

  @Override
  public synchronized boolean isProcessed(UUID messageId) {
    return processed.contains(messageId);
  }
}
