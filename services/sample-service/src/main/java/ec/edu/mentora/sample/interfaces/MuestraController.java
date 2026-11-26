package ec.edu.mentora.sample.interfaces;

import ec.edu.mentora.sample.application.port.in.ObtenerMuestraUseCase;
import ec.edu.mentora.sample.application.port.in.RegistrarMuestraCommand;
import ec.edu.mentora.sample.application.port.in.RegistrarMuestraUseCase;
import ec.edu.mentora.sample.interfaces.rest.api.MuestrasApi;
import ec.edu.mentora.sample.interfaces.rest.model.MuestraRequest;
import ec.edu.mentora.sample.interfaces.rest.model.MuestraResponse;
import org.springframework.web.bind.annotation.RestController;

/**
 * Input adapter: REST endpoints of the samples. It has no business rules. Routes and validations
 * come from {@code MuestrasApi}, generated from libs/contracts/openapi/sample-service.yaml.
 */
@RestController
public class MuestraController implements MuestrasApi {

  private final RegistrarMuestraUseCase registrar;
  private final ObtenerMuestraUseCase obtener;

  /** Creates the controller with the input ports it calls. */
  public MuestraController(RegistrarMuestraUseCase registrar, ObtenerMuestraUseCase obtener) {
    this.registrar = registrar;
    this.obtener = obtener;
  }

  @Override
  public MuestraResponse registrarMuestra(String muestraId, MuestraRequest cuerpo) {
    return MuestraRestMapper.respuesta(
        registrar.ejecutar(new RegistrarMuestraCommand(muestraId, cuerpo.getNombre())));
  }

  @Override
  public MuestraResponse obtenerMuestra(String muestraId) {
    return MuestraRestMapper.respuesta(obtener.ejecutar(muestraId));
  }
}
