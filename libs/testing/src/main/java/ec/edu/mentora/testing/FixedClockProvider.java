package ec.edu.mentora.testing;

import ec.edu.mentora.platform.time.ClockProvider;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;

public final class FixedClockProvider implements ClockProvider {

  private Instant instant;

  public FixedClockProvider(Instant instant) {
    this.instant = instant;
  }

  public void set(Instant instant) {
    this.instant = instant;
  }

  @Override
  public Clock clock() {
    return Clock.fixed(instant, ZoneOffset.UTC);
  }
}
