package ec.edu.mentora.sample;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.boot.SpringApplication;
import org.springframework.context.ConfigurableApplicationContext;

/** The service starts with the profile of each environment and loads its configuration. */
class PerfilesTest {

  @ParameterizedTest
  @ValueSource(strings = {"dev", "qa", "prod"})
  void arrancaConCadaPerfil(String perfil) {
    try (ConfigurableApplicationContext contexto =
        SpringApplication.run(
            SampleApplication.class, "--spring.profiles.active=" + perfil, "--server.port=0")) {
      assertThat(contexto.getEnvironment().getProperty("mentora.environment")).isEqualTo(perfil);
      // Common configuration: every environment runs on Java 21 virtual threads.
      assertThat(contexto.getEnvironment().getProperty("spring.threads.virtual.enabled"))
          .isEqualTo("true");
    }
  }
}
