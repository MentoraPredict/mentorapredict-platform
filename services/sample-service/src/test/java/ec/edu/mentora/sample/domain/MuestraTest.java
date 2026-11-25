package ec.edu.mentora.sample.domain;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.time.Clock;
import java.time.Instant;
import java.time.ZoneOffset;
import org.junit.jupiter.api.Test;

/** Unit test of the domain: no Spring, no database, a fixed clock. */
class MuestraTest {

  private static final Instant AHORA = Instant.parse("2026-11-25T10:00:00Z");
  private static final Clock RELOJ = Clock.fixed(AHORA, ZoneOffset.UTC);

  @Test
  void registraConElInstanteDelRelojInyectado() {
    Muestra muestra = Muestra.registrar("m-1", "Primera", RELOJ);

    assertThat(muestra.registradaEn()).isEqualTo(AHORA);
  }

  @Test
  void rechazaUnNombreEnBlanco() {
    assertThatThrownBy(() -> Muestra.registrar("m-1", " ", RELOJ))
        .isInstanceOf(IllegalArgumentException.class);
  }
}
