package ec.edu.mentora.platform.id;

import java.security.SecureRandom;
import java.time.Instant;
import java.util.UUID;

public final class UuidV7 {

  private static final long VERSION = 0x7000L;
  private static final long VARIANT = 0x8000000000000000L;
  private static final long RANDOM_A_MASK = 0x0FFFL;
  private static final long RANDOM_B_MASK = 0x3FFFFFFFFFFFFFFFL;
  private static final long TIMESTAMP_MASK = 0xFFFFFFFFFFFFL;
  private static final SecureRandom RANDOM = new SecureRandom();

  private UuidV7() {}

  public static UUID fromInstant(Instant instant) {
    long timestamp = instant.toEpochMilli() & TIMESTAMP_MASK;
    long mostSignificantBits = (timestamp << 16) | VERSION | (RANDOM.nextInt() & RANDOM_A_MASK);
    long leastSignificantBits = (RANDOM.nextLong() & RANDOM_B_MASK) | VARIANT;
    return new UUID(mostSignificantBits, leastSignificantBits);
  }
}
