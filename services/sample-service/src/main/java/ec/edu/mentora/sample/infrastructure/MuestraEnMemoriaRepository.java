package ec.edu.mentora.sample.infrastructure;

import ec.edu.mentora.sample.application.port.out.MuestraRepositoryPort;
import ec.edu.mentora.sample.domain.Muestra;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

/** Output adapter that keeps the samples in memory. It moves to the database with MPC-391. */
public final class MuestraEnMemoriaRepository implements MuestraRepositoryPort {

  private final Map<String, Muestra> muestras = new ConcurrentHashMap<>();

  @Override
  public Optional<Muestra> buscarPorId(String id) {
    return Optional.ofNullable(muestras.get(id));
  }

  @Override
  public void guardar(Muestra muestra) {
    muestras.put(muestra.id(), muestra);
  }
}
