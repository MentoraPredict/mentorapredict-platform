package ec.edu.mentora.archrules;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;

import com.tngtech.archunit.base.DescribedPredicate;
import com.tngtech.archunit.core.domain.JavaClass;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;
import java.util.regex.Pattern;

/** Rule of the package layout: a service only has the four hexagonal layers. */
public final class StructureRules {

  private static final Pattern INSIDE_A_SERVICE_PACKAGE =
      Pattern.compile("^ec\\.edu\\.mentora\\.[^.]+\\..+");

  /**
   * Everything below the root package of a service lives in domain, application, infrastructure or
   * interfaces. This also rejects catch-all packages such as util or common (H5).
   */
  @ArchTest
  public static final ArchRule ONLY_THE_FOUR_LAYERS =
      classes()
          .that(areBelowTheRootPackageOfAService())
          .should()
          .resideInAnyPackage(
              "..domain..", "..application..", "..infrastructure..", "..interfaces..")
          .allowEmptyShould(true);

  private static DescribedPredicate<JavaClass> areBelowTheRootPackageOfAService() {
    return DescribedPredicate.describe(
        "are below the root package of a service",
        javaClass -> INSIDE_A_SERVICE_PACKAGE.matcher(javaClass.getPackageName()).matches());
  }

  private StructureRules() {}
}
