package ec.edu.mentora.fixtureviolations.application;

import ec.edu.mentora.fixtureviolations.infrastructure.Store;

/** Fixture, violates H2: the application layer depends on an adapter. */
public final class Handler {

  /** Calls the adapter. */
  public String name() {
    return new Store().id();
  }
}
