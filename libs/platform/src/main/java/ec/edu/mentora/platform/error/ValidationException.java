package ec.edu.mentora.platform.error;

public final class ValidationException extends DomainException {

  private static final long serialVersionUID = 1L;

  public ValidationException(String code, String message) {
    super(code, message);
  }
}
