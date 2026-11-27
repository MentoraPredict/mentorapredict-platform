package ec.edu.mentora.platform.error;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class DomainExceptionTest {

  @Test
  void exposesTheDomainCodeAndMessage() {
    DomainException exception = new NotFoundException("AUL-404", "Classroom not found");

    assertThat(exception.code()).isEqualTo("AUL-404");
    assertThat(exception.getMessage()).isEqualTo("Classroom not found");
  }

  @Test
  void keepsTheCodeInEveryDomainError() {
    assertThat(new ValidationException("AUL-400", "Invalid").code()).isEqualTo("AUL-400");
    assertThat(new ConflictException("AUL-409", "Conflict").code()).isEqualTo("AUL-409");
  }
}
