package ec.edu.mentora.platform.correlation;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

class CorrelationContextTest {

  @AfterEach
  void clearContext() {
    CorrelationContext.clear();
  }

  @Test
  void keepsTheCorrelationIdOfTheCurrentThread() {
    CorrelationContext.set("corr-1");

    assertThat(CorrelationContext.current()).contains("corr-1");
  }

  @Test
  void restoresThePreviousCorrelationId() {
    CorrelationContext.set("outer");

    String result =
        CorrelationContext.callWith("inner", () -> CorrelationContext.current().orElseThrow());

    assertThat(result).isEqualTo("inner");
    assertThat(CorrelationContext.current()).contains("outer");
  }

  @Test
  void removesTheCorrelationIdWhenThereWasNoPreviousValue() {
    CorrelationContext.callWith("inner", () -> "done");

    assertThat(CorrelationContext.current()).isEmpty();
  }
}
