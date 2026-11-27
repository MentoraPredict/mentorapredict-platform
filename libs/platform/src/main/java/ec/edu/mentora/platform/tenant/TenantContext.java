package ec.edu.mentora.platform.tenant;

import java.util.Optional;
import java.util.UUID;

public final class TenantContext {

  private static final ThreadLocal<UUID> CURRENT = new ThreadLocal<>();

  private TenantContext() {}

  public static void set(UUID tenantId) {
    CURRENT.set(tenantId);
  }

  public static Optional<UUID> current() {
    return Optional.ofNullable(CURRENT.get());
  }

  public static UUID require() {
    return current()
        .orElseThrow(() -> new IllegalStateException("No tenant in the current context"));
  }

  public static void clear() {
    CURRENT.remove();
  }
}
