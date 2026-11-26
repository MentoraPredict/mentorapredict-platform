package ec.edu.mentora.sample;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

/** Component test of the health checks and of the Actuator endpoints that are exposed. */
@SpringBootTest
@AutoConfigureMockMvc
class SaludApiTest {

  @Autowired private MockMvc mvc;

  @ParameterizedTest
  @ValueSource(
      strings = {"/actuator/health", "/actuator/health/liveness", "/actuator/health/readiness"})
  void lasSondasRespondenUpSinDetalles(String ruta) throws Exception {
    mvc.perform(get(ruta))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status").value("UP"))
        .andExpect(jsonPath("$.components").doesNotExist())
        .andExpect(jsonPath("$.details").doesNotExist());
  }

  @Test
  void infoEstaExpuesto() throws Exception {
    mvc.perform(get("/actuator/info")).andExpect(status().isOk());
  }

  @ParameterizedTest
  @ValueSource(strings = {"env", "beans", "configprops", "heapdump", "loggers", "metrics"})
  void losDemasEndpointsDeActuatorNoEstanExpuestos(String endpoint) throws Exception {
    mvc.perform(get("/actuator/" + endpoint)).andExpect(status().isNotFound());
  }
}
