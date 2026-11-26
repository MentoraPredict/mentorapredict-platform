package ec.edu.mentora.sample;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

/** Component test: the real wiring of the service, called through HTTP without a network. */
@SpringBootTest
@AutoConfigureMockMvc
class MuestraApiTest {

  @Autowired private MockMvc mvc;

  @Test
  void registraYLuegoConsultaUnaMuestra() throws Exception {
    mvc.perform(
            put("/v1/muestras/m-1")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"nombre\":\"Primera\"}"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.id").value("m-1"));

    mvc.perform(get("/v1/muestras/m-1"))
        .andExpect(status().isOk())
        .andExpect(jsonPath("$.nombre").value("Primera"));
  }

  @Test
  void unaMuestraInexistenteDevuelve404() throws Exception {
    mvc.perform(get("/v1/muestras/no-existe")).andExpect(status().isNotFound());
  }

  @Test
  void unNombreEnBlancoDevuelve400() throws Exception {
    mvc.perform(
            put("/v1/muestras/m-2")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"nombre\":\" \"}"))
        .andExpect(status().isBadRequest());
  }

  @Test
  void unaPeticionSinNombreIncumpleElContratoYDevuelve400() throws Exception {
    mvc.perform(put("/v1/muestras/m-3").contentType(MediaType.APPLICATION_JSON).content("{}"))
        .andExpect(status().isBadRequest());
  }
}
