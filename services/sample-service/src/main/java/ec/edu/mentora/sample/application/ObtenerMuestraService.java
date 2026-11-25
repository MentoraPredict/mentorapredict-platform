package ec.edu.mentora.sample.application;

import ec.edu.mentora.sample.application.port.in.ObtenerMuestraUseCase;
import ec.edu.mentora.sample.application.port.out.MuestraRepositoryPort;
import ec.edu.mentora.sample.domain.Muestra;
import ec.edu.mentora.sample.domain.MuestraNoEncontradaException;

/** Use case: look a sample up. */
public final class ObtenerMuestraService implements ObtenerMuestraUseCase {

  private final MuestraRepositoryPort repositorio;

  /** Creates the use case with the output port it needs. */
  public ObtenerMuestraService(MuestraRepositoryPort repositorio) {
    this.repositorio = repositorio;
  }

  @Override
  public Muestra ejecutar(String id) {
    return repositorio.buscarPorId(id).orElseThrow(() -> new MuestraNoEncontradaException(id));
  }
}
