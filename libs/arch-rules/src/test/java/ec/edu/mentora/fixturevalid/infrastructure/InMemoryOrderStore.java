package ec.edu.mentora.fixturevalid.infrastructure;

import ec.edu.mentora.fixturevalid.domain.Order;
import ec.edu.mentora.fixturevalid.domain.OrderStore;
import java.util.ArrayList;
import java.util.List;

/** Fixture: an output adapter. */
public final class InMemoryOrderStore implements OrderStore {

  private final List<Order> orders = new ArrayList<>();

  @Override
  public void save(Order order) {
    orders.add(order);
  }

  /** Number of saved orders. */
  public int size() {
    return orders.size();
  }
}
