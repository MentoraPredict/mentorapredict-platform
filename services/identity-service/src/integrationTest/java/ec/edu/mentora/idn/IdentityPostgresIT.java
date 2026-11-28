package ec.edu.mentora.idn;

import static org.assertj.core.api.Assertions.assertThat;

import java.nio.file.Path;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.util.TestPropertyValues;
import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.MountableFile;

/** Integration checks using PostgreSQL with separate local application and migration roles. */
@SpringBootTest
@ContextConfiguration(initializers = IdentityPostgresIT.PostgresInitializer.class)
class IdentityPostgresIT {
  @Autowired private JdbcTemplate jdbc;
  @Autowired private Flyway flyway;

  @Test
  void migrationCreatesIdentitySchema() {
    assertThat(flyway.info().applied())
        .extracting(migration -> migration.getVersion().getVersion())
        .contains("1");
    assertThat(flyway.info().pending()).isEmpty();
    assertThat(jdbc.queryForObject("select to_regnamespace('idn') is not null", Boolean.class))
        .isTrue();
  }

  @Test
  void applicationRoleCannotCreateOrBypassRls() {
    assertThat(jdbc.queryForObject("select current_user", String.class)).isEqualTo("idn_app");
    assertThat(
            jdbc.queryForObject(
                "select rolsuper or rolbypassrls from pg_roles where rolname = current_user",
                Boolean.class))
        .isFalse();
    assertThat(
            jdbc.queryForObject(
                "select has_schema_privilege(current_user, 'idn', 'CREATE')", Boolean.class))
        .isFalse();
  }

  /** Starts a real PostgreSQL container using the same role setup as the local environment. */
  static final class PostgresInitializer
      implements ApplicationContextInitializer<ConfigurableApplicationContext> {
    private static final PostgreSQLContainer POSTGRES =
        new PostgreSQLContainer("postgres:17-alpine")
            .withDatabaseName("identity")
            .withCopyFileToContainer(
                MountableFile.forHostPath(
                    Path.of("../../infra/local/identity-postgres/01-roles.sql")),
                "/docker-entrypoint-initdb.d/01-roles.sql");

    @Override
    public void initialize(ConfigurableApplicationContext context) {
      POSTGRES.start();
      TestPropertyValues.of(
              "DB_URL=" + POSTGRES.getJdbcUrl(),
              "DB_USER=idn_app",
              "DB_PASSWORD=idn_app",
              "DB_MIGRATION_USER=idn_migrator",
              "DB_MIGRATION_PASSWORD=idn_migrator")
          .applyTo(context);
    }
  }
}
