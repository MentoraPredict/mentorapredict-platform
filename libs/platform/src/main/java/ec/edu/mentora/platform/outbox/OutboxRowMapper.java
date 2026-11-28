package ec.edu.mentora.platform.outbox;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

final class OutboxRowMapper {

  private OutboxRowMapper() {}

  static OutboxMessage map(ResultSet resultSet) throws SQLException {
    return new OutboxMessage(
        resultSet.getObject(1, UUID.class),
        resultSet.getString(2),
        resultSet.getString(3),
        resultSet.getTimestamp(4).toInstant());
  }
}
