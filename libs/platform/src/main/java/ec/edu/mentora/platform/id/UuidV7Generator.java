package ec.edu.mentora.platform.id;

import java.time.Clock;
import java.util.UUID;

public final class UuidV7Generator implements IdGenerator {

  private final Clock clock;

  public UuidV7Generator(Clock clock) {
    this.clock = clock;
  }

  @Override
  public UUID newId() {
    return UuidV7.fromInstant(clock.instant());
  }
}
