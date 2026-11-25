package ec.edu.mentora.fixtureviolations.interfaces;

import ec.edu.mentora.fixtureviolations.infrastructure.Store;

/** Fixture, violates H3: an input adapter depends on an output adapter. */
public final class UsesInfrastructure {

  /** Calls the output adapter. */
  public String run() {
    return new Store().id();
  }
}
