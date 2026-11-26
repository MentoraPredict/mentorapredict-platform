package ec.edu.mentora.sample.interfaces;

import ec.edu.mentora.sample.domain.Muestra;
import ec.edu.mentora.sample.interfaces.rest.model.MuestraResponse;
import java.time.ZoneOffset;

/** Translates the domain object into the response of the contract. */
final class MuestraRestMapper {

  static MuestraResponse respuesta(Muestra muestra) {
    return new MuestraResponse(
        muestra.id(), muestra.nombre(), muestra.registradaEn().atOffset(ZoneOffset.UTC));
  }

  private MuestraRestMapper() {}
}
