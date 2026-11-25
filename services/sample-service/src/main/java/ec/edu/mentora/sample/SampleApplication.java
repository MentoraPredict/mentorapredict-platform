package ec.edu.mentora.sample;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/** Entry point and composition root of the sample service. */
@SpringBootApplication
public class SampleApplication {

  /** Starts the service. */
  public static void main(String[] args) {
    SpringApplication.run(SampleApplication.class, args);
  }
}
