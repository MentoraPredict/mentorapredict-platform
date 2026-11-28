package ec.edu.mentora.idn;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.servlet.MockMvc;

/** The local documentation describes existing operational routes. */
@SpringBootTest
@AutoConfigureMockMvc
@ActiveProfiles("dev")
class OpenApiDevTest {
  @Autowired private MockMvc mvc;

  @Test
  void documentsHealthAndServesSwaggerUi() throws Exception {
    mvc.perform(get("/v3/api-docs"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.openapi").value(org.hamcrest.Matchers.startsWith("3.1.")))
        .andExpect(jsonPath("$.paths['/actuator/health']").exists());
    mvc.perform(get("/swagger-ui.html")).andExpect(status().is3xxRedirection());
  }
}
