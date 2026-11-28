package ec.edu.mentora.platform.inbox;

import java.util.UUID;

public interface InboxStore {

  boolean tryMarkProcessed(UUID messageId);

  boolean isProcessed(UUID messageId);
}
