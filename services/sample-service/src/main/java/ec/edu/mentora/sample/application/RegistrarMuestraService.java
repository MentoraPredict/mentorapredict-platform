package ec.edu.mentora.sample.application;

import ec.edu.mentora.sample.application.port.in.RegistrarMuestraCommand;
import ec.edu.mentora.sample.application.port.in.RegistrarMuestraUseCase;
import ec.edu.mentora.sample.application.port.out.MuestraRepositoryPort;
import ec.edu.mentora.sample.domain.Muestra;
import java.time.Clock;

/** Use case: register a sample. */
public final class RegistrarMuestraService implements RegistrarMuestraUseCase {

  private final MuestraRepositoryPort repositorio;
  private final Clock reloj;

  /** Creates the use case with its output port and the clock it injects into the domain. */
  public RegistrarMuestraService(MuestraRepositoryPort repositorio, Clock reloj) {
    this.repositorio = repositorio;
    this.reloj = reloj;
  }

  @Override
  public Muestra ejecutar(RegistrarMuestraCommand comando) {
    Muestra muestra = Muestra.registrar(comando.id(), comando.nombre(), reloj);
    repositorio.guardar(muestra);
    return muestra;
  }
}
