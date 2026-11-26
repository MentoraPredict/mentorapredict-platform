package ec.edu.mentora.sample;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.UUID;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.transaction.support.TransactionTemplate;

/**
 * One institution never sees or writes the rows of another (DOC-ARQ-06 section 11). The pool has a
 * single connection, so every statement reuses it and a leaked institution would show.
 */
@PruebaDeIntegracion
class AislamientoRlsIT {

  private static final String INSERTAR =
      "insert into muestra (tenant_id, id, nombre, registrada_en) values (?, 'm-1', 'x', now())";
  private static final String CONTAR = "select count(*) from muestra";

  @Autowired private JdbcTemplate jdbc;
  @Autowired private TransactionTemplate transaccion;

  private final UUID institucionA = UUID.randomUUID();
  private final UUID institucionB = UUID.randomUUID();

  @Test
  void cadaInstitucionSoloVeSusFilas() {
    comoInstitucion(institucionA, () -> jdbc.update(INSERTAR, institucionA));

    assertThat(contarComo(institucionA)).isEqualTo(1);
    assertThat(contarComo(institucionB)).isZero();
  }

  @Test
  void sinInstitucionNoHayFilasAunEnUnaConexionQueYaLaUso() {
    comoInstitucion(institucionA, () -> jdbc.update(INSERTAR, institucionA));

    assertThat(jdbc.queryForObject(CONTAR, Integer.class)).isZero();
  }

  @Test
  void noSePuedeInsertarUnaFilaDeOtraInstitucion() {
    assertThatThrownBy(
            () -> comoInstitucion(institucionA, () -> jdbc.update(INSERTAR, institucionB)))
        .isInstanceOf(DataAccessException.class)
        .hasStackTraceContaining("row-level security");
  }

  private int contarComo(UUID institucion) {
    int[] filas = new int[1];
    comoInstitucion(
        institucion, () -> filas[0] = jdbc.queryForList("select id from muestra").size());
    return filas[0];
  }

  /** Runs the work in a transaction with the institution set, as the service has to do. */
  private void comoInstitucion(UUID institucion, Runnable trabajo) {
    transaccion.executeWithoutResult(
        estado -> {
          jdbc.queryForObject(
              "select set_config('app.tenant_id', ?, true)", String.class, institucion.toString());
          trabajo.run();
        });
  }
}
