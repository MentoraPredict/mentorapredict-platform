package ec.edu.mentora.sample;

import java.nio.file.Path;
import org.springframework.boot.test.util.TestPropertyValues;
import org.springframework.context.ApplicationContextInitializer;
import org.springframework.context.ConfigurableApplicationContext;
import org.testcontainers.postgresql.PostgreSQLContainer;
import org.testcontainers.utility.MountableFile;

/**
 * Real PostgreSQL with the same roles as compose.yml. It does not use {@code @ServiceConnection},
 * which would connect the service as the administrator of the container and skip row-level
 * security: the service and Flyway connect with their own role.
 *
 * <p>It is an initializer, and not a bean, because Spring reads the Flyway properties before it
 * creates any bean. The container is shared by the test run and Testcontainers removes it at the
 * end.
 */
class PostgresPorRoles implements ApplicationContextInitializer<ConfigurableApplicationContext> {

  private static final PostgreSQLContainer POSTGRES =
      new PostgreSQLContainer("postgres:17-alpine")
          .withCopyFileToContainer(
              // Relative to the folder of the service, where Gradle runs the tests.
              MountableFile.forHostPath(Path.of("../../infra/local/postgres/01-roles.sql")),
              "/docker-entrypoint-initdb.d/01-roles.sql");

  @Override
  public void initialize(ConfigurableApplicationContext contexto) {
    POSTGRES.start(); // does nothing if it is already running
    TestPropertyValues.of(
            "DB_URL=" + POSTGRES.getJdbcUrl(),
            "DB_USER=svc_app",
            "DB_PASSWORD=svc_app",
            "DB_MIGRATION_USER=svc_migrator",
            "DB_MIGRATION_PASSWORD=svc_migrator")
        .applyTo(contexto);
  }
}
