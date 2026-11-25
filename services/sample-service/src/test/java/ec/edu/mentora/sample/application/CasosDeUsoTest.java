package ec.edu.mentora.sample.application;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import ec.edu.mentora.sample.application.port.in.RegistrarMuestraCommand;
import ec.edu.mentora.sample.domain.MuestraNoEncontradaException;
import ec.edu.mentora.sample.infrastructure.MuestraEnMemoriaRepository;
import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;

/** Unit test of the use cases against the in-memory adapter, without Spring. */
class CasosDeUsoTest {

  private final MuestraEnMemoriaRepository repositorio = new MuestraEnMemoriaRepository();
  private final RegistrarMuestraService registrar =
      new RegistrarMuestraService(
          repositorio, Clock.fixed(Instant.parse("2026-11-25T10:00:00Z"), ZoneOffset.UTC));
  private final ObtenerMuestraService obtener = new ObtenerMuestraService(repositorio);

  @Test
  void unaMuestraRegistradaSePuedeObtener() {
    registrar.ejecutar(new RegistrarMuestraCommand("m-1", "Primera"));

    assertThat(obtener.ejecutar("m-1").nombre()).isEqualTo("Primera");
  }

  @Test
  void registrarDeNuevoElMismoIdLaReemplaza() {
    registrar.ejecutar(new RegistrarMuestraCommand("m-1", "Primera"));
    registrar.ejecutar(new RegistrarMuestraCommand("m-1", "Segunda"));

    assertThat(obtener.ejecutar("m-1").nombre()).isEqualTo("Segunda");
  }

  @Test
  void obtenerUnaMuestraInexistenteFalla() {
    assertThatThrownBy(() -> obtener.ejecutar("no-existe"))
        .isInstanceOf(MuestraNoEncontradaException.class);
  }
}
