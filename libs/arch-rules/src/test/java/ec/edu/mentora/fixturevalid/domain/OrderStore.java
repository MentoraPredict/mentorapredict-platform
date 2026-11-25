package ec.edu.mentora.fixturevalid.domain;

/** Fixture: an output port. */
public interface OrderStore {

  /** Saves an order. */
  void save(Order order);
}
