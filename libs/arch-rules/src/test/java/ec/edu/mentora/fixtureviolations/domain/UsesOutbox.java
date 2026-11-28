package ec.edu.mentora.fixtureviolations.domain;

import ec.edu.mentora.platform.outbox.OutboxStore;

public final class UsesOutbox {

  public int pending(OutboxStore outbox) {
    return outbox.pending(1).length;
  }
}
