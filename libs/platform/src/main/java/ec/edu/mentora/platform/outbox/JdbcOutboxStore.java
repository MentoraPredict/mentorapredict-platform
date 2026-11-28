package ec.edu.mentora.platform.outbox;

import java.util.UUID;
import javax.sql.DataSource;

public final class JdbcOutboxStore implements OutboxStore {

  private final OutboxJdbc jdbc;

  public JdbcOutboxStore(DataSource dataSource) {
    this.jdbc = new OutboxJdbc(dataSource);
  }

  @Override
  public void append(OutboxMessage message) {
    jdbc.append(message);
  }

  @Override
  public OutboxMessage[] pending(int limit) {
    return jdbc.pending(limit);
  }

  @Override
  public void markPublished(UUID id) {
    jdbc.markPublished(id);
  }
}
