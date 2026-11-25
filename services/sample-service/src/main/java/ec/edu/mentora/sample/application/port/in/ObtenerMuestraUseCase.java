package ec.edu.mentora.sample.application.port.in;

import ec.edu.mentora.sample.domain.Muestra;

/** Input port: look a sample up by its identifier. */
public interface ObtenerMuestraUseCase {

  /**
   * Returns the sample.
   *
   * @throws ec.edu.mentora.sample.domain.MuestraNoEncontradaException if it does not exist
   */
  Muestra ejecutar(String id);
}
