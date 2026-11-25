package ec.edu.mentora.fixturevalid.application;

import ec.edu.mentora.fixturevalid.domain.Order;
import ec.edu.mentora.fixturevalid.domain.OrderStore;
import java.time.Clock;

/** Fixture: a use case that only depends on the domain. */
public final class PlaceOrder {

  private final OrderStore store;
  private final Clock clock;

  /** Creates the use case with its output port and its clock. */
  public PlaceOrder(OrderStore store, Clock clock) {
    this.store = store;
    this.clock = clock;
  }

  /** Places an order. */
  public Order place(String id) {
    Order order = Order.create(id, clock);
    store.save(order);
    return order;
  }
}
