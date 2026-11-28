package ec.edu.mentora.platform.fixture;

import ec.edu.mentora.fixturevalid.domain.Order;
import java.time.Clock;

public final class UsesService {

  public Order order(Clock clock) {
    return Order.create("order-1", clock);
  }
}
