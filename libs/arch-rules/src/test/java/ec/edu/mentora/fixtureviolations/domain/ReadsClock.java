package ec.edu.mentora.fixtureviolations.domain;

import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.UUID;

/** Fixture, violates H10: the domain reads the clock and random sources directly. */
public final class ReadsClock {

  /** Reads the system clock. */
  public Instant now() {
    return Instant.now();
  }

  /** Reads the system date. */
  public LocalDate today() {
    return LocalDate.now(ZoneId.of("America/Guayaquil"));
  }

  /** Reads the system clock in milliseconds. */
  public long millis() {
    return System.currentTimeMillis();
  }

  /** Generates a random identifier. */
  public UUID newId() {
    return UUID.randomUUID();
  }

  /** Generates a random number. */
  public double roll() {
    return Math.random();
  }
}
