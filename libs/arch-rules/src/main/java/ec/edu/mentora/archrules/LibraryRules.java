package ec.edu.mentora.archrules;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.base.DescribedPredicate;
import com.tngtech.archunit.core.domain.JavaClass;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

public final class LibraryRules {

  @ArchTest
  public static final ArchRule H5_LIBRARIES_DO_NOT_DEPEND_ON_SERVICES =
      noClasses()
          .that()
          .resideInAnyPackage(
              "ec.edu.mentora.platform..", "ec.edu.mentora.archrules..", "ec.edu.mentora.testing..")
          .should()
          .dependOnClassesThat(areServiceClasses())
          .allowEmptyShould(true)
          .as("H5 shared libraries must not contain service business logic");

  private static DescribedPredicate<JavaClass> areServiceClasses() {
    return DescribedPredicate.describe(
        "are service classes",
        javaClass -> {
          String root = PackageRoots.of(javaClass.getPackageName());
          return root != null && !PackageRoots.isLibrary(root);
        });
  }

  private LibraryRules() {}
}
