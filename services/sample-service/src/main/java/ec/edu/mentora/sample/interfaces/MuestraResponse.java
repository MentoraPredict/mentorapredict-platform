package ec.edu.mentora.sample.interfaces;

import ec.edu.mentora.sample.domain.Muestra;
import java.time.Instant;

/**
 * Body of the response that describes a sample.
 *
 * @param id identifier of the sample
 * @param nombre name of the sample
 * @param registradaEn instant at which the sample was registered
 */
public record MuestraResponse(String id, String nombre, Instant registradaEn) {

  /** Builds the response from the domain object. */
  public static MuestraResponse desde(Muestra muestra) {
    return new MuestraResponse(muestra.id(), muestra.nombre(), muestra.registradaEn());
  }
}
