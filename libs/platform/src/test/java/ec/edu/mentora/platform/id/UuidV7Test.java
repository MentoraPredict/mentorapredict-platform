package ec.edu.mentora.platform.id;

import static org.assertj.core.api.Assertions.assertThat;

import java.time.Instant;
import java.util.UUID;
import org.junit.jupiter.api.Test;

class UuidV7Test {

  @Test
  void generatesVersion7WithTheIetfVariant() {
    UUID id = UuidV7.fromInstant(Instant.parse("2026-11-27T10:15:30Z"));

    assertThat(id.version()).isEqualTo(7);
    assertThat(id.variant()).isEqualTo(2);
  }

  @Test
  void keepsTheInstantInTheFirst48Bits() {
    Instant instant = Instant.parse("2026-11-27T10:15:30Z");
    UUID id = UuidV7.fromInstant(instant);

    assertThat(id.getMostSignificantBits() >>> 16).isEqualTo(instant.toEpochMilli());
  }

  @Test
  void generatesDifferentIdentifiers() {
    Instant instant = Instant.parse("2026-11-27T10:15:30Z");

    assertThat(UuidV7.fromInstant(instant)).isNotEqualTo(UuidV7.fromInstant(instant));
  }
}
