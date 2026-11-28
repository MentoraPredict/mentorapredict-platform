package ec.edu.mentora.quiz;

import ec.edu.mentora.platform.id.IdGenerator;
import ec.edu.mentora.platform.id.UuidV7Generator;
import ec.edu.mentora.platform.time.ClockProvider;
import ec.edu.mentora.platform.time.SystemClockProvider;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration(proxyBeanMethods = false)
class ConfiguracionBeans {

  @Bean
  ClockProvider clockProvider() {
    return new SystemClockProvider();
  }

  @Bean
  IdGenerator idGenerator(ClockProvider clockProvider) {
    return new UuidV7Generator(clockProvider.clock());
  }
}
