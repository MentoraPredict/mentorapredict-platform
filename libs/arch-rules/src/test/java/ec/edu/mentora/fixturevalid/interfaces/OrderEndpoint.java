package ec.edu.mentora.fixturevalid.interfaces;

import ec.edu.mentora.fixturevalid.application.PlaceOrder;

/** Fixture: an input adapter that only depends on the application layer. */
public final class OrderEndpoint {

  private final PlaceOrder placeOrder;

  /** Creates the endpoint with the use case it calls. */
  public OrderEndpoint(PlaceOrder placeOrder) {
    this.placeOrder = placeOrder;
  }

  /** Handles a request. */
  public String handle(String id) {
    return placeOrder.place(id).id();
  }
}
