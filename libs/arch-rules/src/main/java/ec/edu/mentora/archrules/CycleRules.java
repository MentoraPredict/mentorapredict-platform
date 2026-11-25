package ec.edu.mentora.archrules;

import static com.tngtech.archunit.library.dependencies.SlicesRuleDefinition.slices;

import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

/** Rule H8: no circular dependencies (DOC-CAL-08 section 3). */
public final class CycleRules {

  /** H8: the layers of a service (ec.edu.mentora.&lt;svc&gt;.&lt;layer&gt;) form no cycle. */
  @ArchTest
  public static final ArchRule H8_LAYERS_HAVE_NO_CYCLES =
      slices().matching("ec.edu.mentora.*.(*)..").should().beFreeOfCycles().allowEmptyShould(true);

  private CycleRules() {}
}
