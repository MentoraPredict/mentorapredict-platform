package ec.edu.mentora.sample;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.testcontainers.kafka.KafkaContainer;

/**
 * Real Kafka for the integration tests. {@code @ServiceConnection} points Spring Boot at the
 * container, so there is nothing to configure. PostgreSQL is in {@link PostgresPorRoles}. Keep the
 * image versions in line with {@code compose.yml}.
 */
@TestConfiguration(proxyBeanMethods = false)
class ContenedoresConfig {

  @Bean
  @ServiceConnection
  KafkaContainer kafka() {
    return new KafkaContainer("apache/kafka:4.0.0");
  }
}
