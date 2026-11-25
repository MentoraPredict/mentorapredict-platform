package ec.edu.mentora.sample.domain;

/** Domain error: the requested sample does not exist. */
public final class MuestraNoEncontradaException extends RuntimeException {

  private static final long serialVersionUID = 1L;

  /** Creates the error for the given sample identifier. */
  public MuestraNoEncontradaException(String id) {
    super("Sample not found: " + id);
  }
}
