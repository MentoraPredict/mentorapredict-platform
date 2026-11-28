package ec.edu.mentora.idn;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.test.web.servlet.MockMvc;

/** Documentation endpoints must not be enabled without an explicit profile. */
@SpringBootTest
@AutoConfigureMockMvc
class OpenApiDefaultTest {
  @Autowired private MockMvc mvc;

  @Test
  void documentationIsDisabledByDefault() throws Exception {
    mvc.perform(get("/v3/api-docs")).andExpect(status().isNotFound());
    mvc.perform(get("/swagger-ui.html")).andExpect(status().isNotFound());
  }
}
