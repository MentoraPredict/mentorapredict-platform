package ec.edu.mentora.sample;

import static org.assertj.core.api.Assertions.assertThat;

import org.apache.kafka.clients.admin.Admin;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.kafka.core.KafkaAdmin;

/** Proves the service can reach a real PostgreSQL and a real Kafka started by Testcontainers. */
@SpringBootTest
@Import(ContenedoresConfig.class)
class InfraestructuraLocalIT {

  @Autowired private JdbcTemplate jdbc;
  @Autowired private KafkaAdmin kafkaAdmin;

  @Test
  void postgresResponde() {
    assertThat(jdbc.queryForObject("select 1", Integer.class)).isEqualTo(1);
  }

  @Test
  void kafkaResponde() throws Exception {
    try (Admin admin = Admin.create(kafkaAdmin.getConfigurationProperties())) {
      assertThat(admin.describeCluster().nodes().get()).isNotEmpty();
    }
  }
}
