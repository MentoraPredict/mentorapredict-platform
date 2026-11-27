package ec.edu.mentora.fixtureviolations.infrastructure;

import java.sql.SQLException;
import javax.sql.DataSource;

public final class OrderRepository {

  public boolean exists(DataSource dataSource, String id) throws SQLException {
    try (var connection = dataSource.getConnection()) {
      return connection.isValid(0) && !id.isBlank();
    }
  }
}
