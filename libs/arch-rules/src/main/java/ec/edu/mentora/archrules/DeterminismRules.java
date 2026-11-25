package ec.edu.mentora.archrules;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.base.DescribedPredicate;
import com.tngtech.archunit.core.domain.JavaMethodCall;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;
import java.util.Set;

/** Rule H10: the domain gets the clock and randomness injected (DOC-CAL-08 section 3). */
public final class DeterminismRules {

  private static final Set<String> FORBIDDEN_CALLS =
      Set.of(
          "java.lang.System.currentTimeMillis",
          "java.lang.System.nanoTime",
          "java.lang.Math.random",
          "java.util.UUID.randomUUID",
          "java.util.concurrent.ThreadLocalRandom.current",
          "java.time.Clock.systemUTC",
          "java.time.Clock.systemDefaultZone");

  /** H10: no direct calls to the system clock or to random sources inside the domain. */
  @ArchTest
  public static final ArchRule H10_DOMAIN_HAS_NO_CLOCK_OR_RANDOM =
      noClasses()
          .that()
          .resideInAPackage("..domain..")
          .should()
          .callMethodWhere(readsClockOrRandom())
          .allowEmptyShould(true);

  private static DescribedPredicate<JavaMethodCall> readsClockOrRandom() {
    return DescribedPredicate.describe(
        "read the system clock or a random source",
        call -> {
          String owner = call.getTargetOwner().getFullName();
          boolean isNowOfJavaTime = owner.startsWith("java.time.") && call.getName().equals("now");
          return isNowOfJavaTime || FORBIDDEN_CALLS.contains(owner + "." + call.getName());
        });
  }

  private DeterminismRules() {}
}
