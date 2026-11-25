package ec.edu.mentora.sample.interfaces;

import ec.edu.mentora.sample.domain.MuestraNoEncontradaException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ProblemDetail;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/** Translates domain errors into HTTP responses, in one place (DOC-CAL-08 section 5). */
@RestControllerAdvice
public class ManejadorDeErrores {

  /** A missing sample is a 404. */
  @ExceptionHandler(MuestraNoEncontradaException.class)
  public ProblemDetail noEncontrada(MuestraNoEncontradaException error) {
    return ProblemDetail.forStatusAndDetail(HttpStatus.NOT_FOUND, error.getMessage());
  }

  /** A request that breaks a domain invariant is a 400. */
  @ExceptionHandler(IllegalArgumentException.class)
  public ProblemDetail solicitudInvalida(IllegalArgumentException error) {
    return ProblemDetail.forStatusAndDetail(HttpStatus.BAD_REQUEST, error.getMessage());
  }
}
