package ec.edu.mentora.sample.application.port.in;

import ec.edu.mentora.sample.domain.Muestra;

/** Input port: register a sample. Registering the same id again replaces it (idempotent). */
public interface RegistrarMuestraUseCase {

  /** Registers the sample and returns it. */
  Muestra ejecutar(RegistrarMuestraCommand comando);
}
