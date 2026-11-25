package ec.edu.mentora.sample.domain;

import java.time.Clock;
import java.time.Instant;

/**
 * Example aggregate of the template. Replace it with the real domain of the service.
 *
 * @param id identifier of the sample, never blank
 * @param nombre name of the sample, never blank
 * @param registradaEn instant at which the sample was registered
 */
public record Muestra(String id, String nombre, Instant registradaEn) {

  /** Validates the invariants of the aggregate. */
  public Muestra {
    if (id.isBlank() || nombre.isBlank()) {
      throw new IllegalArgumentException("A sample needs an id and a name");
    }
  }

  /** Registers a sample at the instant given by the injected clock (rule H10). */
  public static Muestra registrar(String id, String nombre, Clock reloj) {
    return new Muestra(id, nombre, reloj.instant());
  }
}
