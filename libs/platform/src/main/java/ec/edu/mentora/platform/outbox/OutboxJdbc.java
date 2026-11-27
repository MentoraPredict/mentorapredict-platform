package ec.edu.mentora.platform.outbox;

import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.UUID;
import javax.sql.DataSource;

final class OutboxJdbc {

  private static final String INSERT =
      "INSERT INTO outbox_message (id, topic, payload, occurred_at) VALUES (?, ?, ?, ?)";
  private static final String PENDING =
      "SELECT id, topic, payload, occurred_at FROM outbox_message "
          + "WHERE published_at IS NULL ORDER BY occurred_at LIMIT ?";
  private static final String MARK_PUBLISHED =
      "UPDATE outbox_message SET published_at = CURRENT_TIMESTAMP WHERE id = ?";

  private final DataSource dataSource;

  OutboxJdbc(DataSource dataSource) {
    this.dataSource = dataSource;
  }

  void append(OutboxMessage message) {
    try (var connection = dataSource.getConnection();
        var statement = connection.prepareStatement(INSERT)) {
      statement.setObject(1, message.id());
      statement.setString(2, message.topic());
      statement.setString(3, message.payload());
      statement.setTimestamp(4, Timestamp.from(message.occurredAt()));
      statement.executeUpdate();
    } catch (SQLException exception) {
      throw new IllegalStateException("Could not append the outbox message", exception);
    }
  }

  OutboxMessage[] pending(int limit) {
    try (var connection = dataSource.getConnection();
        var statement = connection.prepareStatement(PENDING)) {
      statement.setInt(1, limit);
      try (var resultSet = statement.executeQuery()) {
        OutboxMessage[] messages = new OutboxMessage[limit];
        int count = 0;
        while (resultSet.next() && count < limit) {
          messages[count] = OutboxRowMapper.map(resultSet);
          count++;
        }
        return messages;
      }
    } catch (SQLException exception) {
      throw new IllegalStateException("Could not read pending outbox messages", exception);
    }
  }

  void markPublished(UUID id) {
    try (var connection = dataSource.getConnection();
        var statement = connection.prepareStatement(MARK_PUBLISHED)) {
      statement.setObject(1, id);
      statement.executeUpdate();
    } catch (SQLException exception) {
      throw new IllegalStateException("Could not mark the outbox message as published", exception);
    }
  }
}
