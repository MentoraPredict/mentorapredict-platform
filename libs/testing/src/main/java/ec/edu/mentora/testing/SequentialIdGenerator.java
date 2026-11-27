package ec.edu.mentora.testing;

import ec.edu.mentora.platform.id.IdGenerator;
import java.util.UUID;
import java.util.concurrent.atomic.AtomicLong;

public final class SequentialIdGenerator implements IdGenerator {

  private final AtomicLong sequence = new AtomicLong();

  @Override
  public UUID newId() {
    return new UUID(0L, sequence.incrementAndGet());
  }
}
