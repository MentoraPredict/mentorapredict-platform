package ec.edu.mentora.sample;

import static org.assertj.core.api.Assertions.assertThat;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;

/** The migrations apply on an empty database and leave a safe schema (DOC-ARQ-06 section 11). */
@PruebaDeIntegracion
class MigracionesIT {

  @Autowired private Flyway flyway;
  @Autowired private JdbcTemplate jdbc;

  @Test
  void lasMigracionesSeAplicanAlArrancarSobreUnaBaseVacia() {
    assertThat(flyway.info().applied())
        .extracting(migracion -> migracion.getVersion().getVersion())
        .contains("1");
    assertThat(flyway.info().pending()).isEmpty();
  }

  @Test
  void todaTablaTieneTenantIdConRlsForzadaYPolitica() {
    // Any table without protection is listed; only the history table of Flyway is allowed.
    assertThat(
            jdbc.queryForList(
                """
                select c.relname from pg_class c
                where c.relnamespace = 'public'::regnamespace and c.relkind in ('r', 'p')
                  and c.relname <> 'flyway_schema_history'
                  and not (
                    c.relrowsecurity and c.relforcerowsecurity
                    and exists (select 1 from pg_policy p where p.polrelid = c.oid)
                    and exists (
                      select 1 from pg_index i
                      join pg_attribute a
                        on a.attrelid = c.oid and a.attnum = any(i.indkey)
                      where i.indrelid = c.oid and i.indisprimary and a.attname = 'tenant_id'))
                """,
                String.class))
        .isEmpty();
  }

  @Test
  void elServicioUsaUnRolQueNoPuedeSaltarseRlsNiEsPropietario() {
    assertThat(jdbc.queryForObject("select current_user", String.class)).isEqualTo("svc_app");
    assertThat(
            jdbc.queryForObject(
                "select rolsuper or rolbypassrls from pg_roles where rolname = current_user",
                Boolean.class))
        .isFalse();
    assertThat(
            jdbc.queryForObject(
                "select count(*) from pg_tables where tableowner = current_user", Integer.class))
        .isZero();
  }
}
