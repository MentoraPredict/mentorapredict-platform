package ec.edu.mentora.testing;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

class SequentialIdGeneratorTest {

  @Test
  void returnsADifferentIdentifierOnEveryCall() {
    SequentialIdGenerator generator = new SequentialIdGenerator();

    assertThat(generator.newId()).isNotEqualTo(generator.newId());
  }
}
