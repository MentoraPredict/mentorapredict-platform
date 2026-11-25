package ec.edu.mentora.sample;

import ec.edu.mentora.sample.application.ObtenerMuestraService;
import ec.edu.mentora.sample.application.RegistrarMuestraService;
import ec.edu.mentora.sample.infrastructure.MuestraEnMemoriaRepository;
import java.time.Clock;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * Composition root: the only place that knows both the use cases and their adapters. The domain and
 * the application layer stay free of Spring annotations.
 */
@Configuration(proxyBeanMethods = false)
class ConfiguracionBeans {

  @Bean
  Clock reloj() {
    return Clock.systemUTC();
  }

  @Bean
  MuestraEnMemoriaRepository muestraRepository() {
    return new MuestraEnMemoriaRepository();
  }

  @Bean
  RegistrarMuestraService registrarMuestra(MuestraEnMemoriaRepository repositorio, Clock reloj) {
    return new RegistrarMuestraService(repositorio, reloj);
  }

  @Bean
  ObtenerMuestraService obtenerMuestra(MuestraEnMemoriaRepository repositorio) {
    return new ObtenerMuestraService(repositorio);
  }
}
