package ec.edu.mentora.idn;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.params.ParameterizedTest;
import org.junit.jupiter.params.provider.ValueSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

/** Checks health probes and prevents exposure of operational details. */
@SpringBootTest
@AutoConfigureMockMvc
class SaludApiTest {
  @Autowired private MockMvc mvc;

  @ParameterizedTest
  @ValueSource(
      strings = {"/actuator/health", "/actuator/health/liveness", "/actuator/health/readiness"})
  void healthIsUpWithoutDetails(String path) throws Exception {
    mvc.perform(get(path))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.status").value("UP"))
        .andExpect(jsonPath("$.details").doesNotExist());
  }

  @ParameterizedTest
  @ValueSource(strings = {"env", "beans", "configprops", "heapdump"})
  void sensitiveActuatorEndpointsAreNotExposed(String endpoint) throws Exception {
    mvc.perform(get("/actuator/" + endpoint)).andExpect(status().isNotFound());
  }
}
