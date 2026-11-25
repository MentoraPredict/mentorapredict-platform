package ec.edu.mentora.sample.interfaces;

import ec.edu.mentora.sample.application.port.in.ObtenerMuestraUseCase;
import ec.edu.mentora.sample.application.port.in.RegistrarMuestraCommand;
import ec.edu.mentora.sample.application.port.in.RegistrarMuestraUseCase;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/** Input adapter: REST endpoints of the samples. It has no business rules. */
@RestController
@RequestMapping("/v1/muestras")
public class MuestraController {

  private final RegistrarMuestraUseCase registrar;
  private final ObtenerMuestraUseCase obtener;

  /** Creates the controller with the input ports it calls. */
  public MuestraController(RegistrarMuestraUseCase registrar, ObtenerMuestraUseCase obtener) {
    this.registrar = registrar;
    this.obtener = obtener;
  }

  /** Registers a sample; repeating the request with the same id replaces it. */
  @PutMapping("/{id}")
  public MuestraResponse registrar(@PathVariable String id, @RequestBody MuestraRequest cuerpo) {
    return MuestraResponse.desde(
        registrar.ejecutar(new RegistrarMuestraCommand(id, cuerpo.nombre())));
  }

  /** Returns a sample, or 404 if it does not exist. */
  @GetMapping("/{id}")
  public MuestraResponse obtener(@PathVariable String id) {
    return MuestraResponse.desde(obtener.ejecutar(id));
  }
}
