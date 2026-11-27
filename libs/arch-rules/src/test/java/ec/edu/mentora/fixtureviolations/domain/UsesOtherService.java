package ec.edu.mentora.fixtureviolations.domain;

import ec.edu.mentora.fixturevalid.domain.Order;
import java.time.Clock;

public final class UsesOtherService {

  public Order order(Clock clock) {
    return Order.create("order-1", clock);
  }
}
