package ec.edu.mentora.platform.time;

import java.time.Clock;

public final class SystemClockProvider implements ClockProvider {

  @Override
  public Clock clock() {
    return Clock.systemUTC();
  }
}
