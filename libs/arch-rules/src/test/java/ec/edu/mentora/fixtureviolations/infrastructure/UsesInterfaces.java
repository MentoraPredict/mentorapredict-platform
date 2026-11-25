package ec.edu.mentora.fixtureviolations.infrastructure;

import ec.edu.mentora.fixtureviolations.interfaces.Endpoint;

/** Fixture, violates H3: an output adapter depends on an input adapter. */
public final class UsesInterfaces {

  /** Calls the input adapter. */
  public String run() {
    return new Endpoint().name();
  }
}
