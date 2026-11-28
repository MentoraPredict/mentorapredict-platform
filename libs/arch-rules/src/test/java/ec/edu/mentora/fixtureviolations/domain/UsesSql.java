package ec.edu.mentora.fixtureviolations.domain;

import java.sql.Connection;

public final class UsesSql {

  public Connection connection(Connection connection) {
    return connection;
  }
}
