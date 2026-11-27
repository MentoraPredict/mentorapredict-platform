package ec.edu.mentora.platform.tenant;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

import java.util.UUID;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.Test;

class TenantContextTest {

  @AfterEach
  void clearContext() {
    TenantContext.clear();
  }

  @Test
  void keepsTheTenantOfTheCurrentThread() {
    UUID tenantId = UUID.randomUUID();
    TenantContext.set(tenantId);

    assertThat(TenantContext.current()).contains(tenantId);
  }

  @Test
  void requiresATenant() {
    assertThatThrownBy(TenantContext::require).isInstanceOf(IllegalStateException.class);
  }
}
