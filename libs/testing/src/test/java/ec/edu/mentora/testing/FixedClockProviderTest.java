package ec.edu.mentora.testing;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import org.junit.jupiter.api.Test;

class FixedClockProviderTest {

  @Test
  void returnsTheConfiguredInstant() {
    FixedClockProvider provider = new FixedClockProvider(Instant.parse("2026-11-27T10:15:30Z"));

    assertThat(provider.clock().instant()).isEqualTo(Instant.parse("2026-11-27T10:15:30Z"));
  }

  @Test
  void movesTheClockWhenTheInstantChanges() {
    FixedClockProvider provider = new FixedClockProvider(Instant.parse("2026-11-27T10:15:30Z"));

    provider.set(Instant.parse("2026-11-27T11:00:00Z"));

    assertThat(provider.clock().instant()).isEqualTo(Instant.parse("2026-11-27T11:00:00Z"));
  }
}
