package ec.edu.mentora.platform.inbox;

import java.util.UUID;
import javax.sql.DataSource;

public final class JdbcInboxStore implements InboxStore {

  private final InboxJdbc jdbc;

  public JdbcInboxStore(DataSource dataSource) {
    this.jdbc = new InboxJdbc(dataSource);
  }

  @Override
  public boolean tryMarkProcessed(UUID messageId) {
    return jdbc.tryMarkProcessed(messageId);
  }

  @Override
  public boolean isProcessed(UUID messageId) {
    return jdbc.isProcessed(messageId);
  }
}
