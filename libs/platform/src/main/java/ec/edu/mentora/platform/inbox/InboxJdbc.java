package ec.edu.mentora.platform.inbox;

import java.sql.SQLException;
import java.util.UUID;
import javax.sql.DataSource;

final class InboxJdbc {

  private static final String INSERT =
      "INSERT INTO inbox_message (message_id) VALUES (?) ON CONFLICT (message_id) DO NOTHING";
  private static final String EXISTS = "SELECT 1 FROM inbox_message WHERE message_id = ?";

  private final DataSource dataSource;

  InboxJdbc(DataSource dataSource) {
    this.dataSource = dataSource;
  }

  boolean tryMarkProcessed(UUID messageId) {
    try (var connection = dataSource.getConnection();
        var statement = connection.prepareStatement(INSERT)) {
      statement.setObject(1, messageId);
      return statement.executeUpdate() == 1;
    } catch (SQLException exception) {
      throw new IllegalStateException("Could not mark the inbox message as processed", exception);
    }
  }

  boolean isProcessed(UUID messageId) {
    try (var connection = dataSource.getConnection();
        var statement = connection.prepareStatement(EXISTS)) {
      statement.setObject(1, messageId);
      try (var resultSet = statement.executeQuery()) {
        return resultSet.next();
      }
    } catch (SQLException exception) {
      throw new IllegalStateException("Could not read the inbox message", exception);
    }
  }
}
