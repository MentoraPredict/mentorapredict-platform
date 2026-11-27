package ec.edu.mentora.platform.correlation;

import java.util.Optional;
import java.util.function.Supplier;

public final class CorrelationContext {

  private static final ThreadLocal<String> CURRENT = new ThreadLocal<>();

  private CorrelationContext() {}

  public static void set(String correlationId) {
    CURRENT.set(correlationId);
  }

  public static Optional<String> current() {
    return Optional.ofNullable(CURRENT.get());
  }

  public static void clear() {
    CURRENT.remove();
  }

  public static <T> T callWith(String correlationId, Supplier<T> action) {
    String previous = CURRENT.get();
    CURRENT.set(correlationId);
    try {
      return action.get();
    } finally {
      if (previous == null) {
        CURRENT.remove();
      } else {
        CURRENT.set(previous);
      }
    }
  }
}
