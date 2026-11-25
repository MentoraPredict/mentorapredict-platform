package ec.edu.mentora.fixtureviolations.infrastructure;

import ec.edu.mentora.fixtureviolations.application.Handler;

/** Fixture, closes a cycle (H8) with the application layer. */
public final class Store {

  /** Identifies the store. */
  public String id() {
    return "store";
  }

  /** Names the handler that uses it. */
  public String handlerName(Handler handler) {
    return handler.name();
  }
}
