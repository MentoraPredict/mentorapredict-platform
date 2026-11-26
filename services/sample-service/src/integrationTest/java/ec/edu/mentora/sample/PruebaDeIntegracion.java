package ec.edu.mentora.sample;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.test.context.ContextConfiguration;

/**
 * The whole service on real containers. All the tests that use it share one Spring context. The
 * pool of the service has a single connection, so every statement reuses it: a test sees at once if
 * an institution stays set on the connection.
 */
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
@SpringBootTest(properties = "spring.datasource.hikari.maximum-pool-size=1")
@Import(ContenedoresConfig.class)
@ContextConfiguration(initializers = PostgresPorRoles.class)
@interface PruebaDeIntegracion {}
