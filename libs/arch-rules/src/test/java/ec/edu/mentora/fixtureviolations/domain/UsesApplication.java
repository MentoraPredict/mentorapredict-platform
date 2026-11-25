package ec.edu.mentora.fixtureviolations.domain;

import ec.edu.mentora.fixtureviolations.application.Handler;

/** Fixture, violates H1: the domain depends on the application layer. */
public final class UsesApplication {

  /** Calls the application layer. */
  public String run() {
    return new Handler().name();
  }
}
