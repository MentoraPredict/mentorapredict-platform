package ec.edu.mentora.sample;

import org.springframework.boot.test.context.TestConfiguration;
import org.springframework.boot.testcontainers.service.connection.ServiceConnection;
import org.springframework.context.annotation.Bean;
import org.testcontainers.kafka.KafkaContainer;
import org.testcontainers.postgresql.PostgreSQLContainer;

/**
 * Real PostgreSQL and Kafka for the integration tests. {@code @ServiceConnection} points Spring
 * Boot at the containers, so there is no URL, user or password to configure. Keep the image
 * versions in line with {@code compose.yml}.
 */
@TestConfiguration(proxyBeanMethods = false)
class ContenedoresConfig {

  @Bean
  @ServiceConnection
  PostgreSQLContainer postgres() {
    return new PostgreSQLContainer("postgres:17-alpine");
  }

  @Bean
  @ServiceConnection
  KafkaContainer kafka() {
    return new KafkaContainer("apache/kafka:4.0.0");
  }
}
