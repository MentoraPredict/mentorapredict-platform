package ec.edu.mentora.idn;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** Entry point for the identity service. */
@SpringBootApplication
public class IdentityApplication {

  /** Starts the identity service. */
  public static void main(String[] args) {
    SpringApplication.run(IdentityApplication.class, args);
  }
}
