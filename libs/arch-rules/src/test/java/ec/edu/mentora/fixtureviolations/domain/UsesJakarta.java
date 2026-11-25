package ec.edu.mentora.fixtureviolations.domain;

import jakarta.annotation.PostConstruct;

/** Fixture, violates H1: the domain depends on Jakarta. */
public final class UsesJakarta {

  /** Runs after construction. */
  @PostConstruct
  public void init() {}
}
