package ec.edu.mentora.sample.application.port.out;

import ec.edu.mentora.sample.domain.Muestra;
import java.util.Optional;

/** Output port: how the application reads and stores samples, without knowing the database. */
public interface MuestraRepositoryPort {

  /** Finds a sample by its identifier. */
  Optional<Muestra> buscarPorId(String id);

  /** Stores a sample, replacing any previous one with the same id. */
  void guardar(Muestra muestra);
}
