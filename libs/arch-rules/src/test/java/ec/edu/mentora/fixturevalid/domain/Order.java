package ec.edu.mentora.fixturevalid.domain;

import java.time.Clock;
import java.time.Instant;

/** Fixture: a domain object that gets the clock injected instead of reading it. */
public record Order(String id, Instant createdAt) {

  /** Creates an order at the instant given by the injected clock. */
  public static Order create(String id, Clock clock) {
    return new Order(id, clock.instant());
  }
}
