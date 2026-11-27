package ec.edu.mentora.archrules;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;

import com.tngtech.archunit.core.domain.Dependency;
import com.tngtech.archunit.core.domain.JavaClass;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchCondition;
import com.tngtech.archunit.lang.ArchRule;
import com.tngtech.archunit.lang.ConditionEvents;
import com.tngtech.archunit.lang.SimpleConditionEvent;

public final class ServiceIsolationRules {

  @ArchTest
  public static final ArchRule H4_SERVICES_DO_NOT_DEPEND_ON_OTHER_SERVICES =
      classes()
          .that()
          .resideInAPackage("ec.edu.mentora.*..")
          .should(dependOnlyOnTheirOwnService())
          .allowEmptyShould(true)
          .as("H4 a service must not depend on another service");

  private static ArchCondition<JavaClass> dependOnlyOnTheirOwnService() {
    return new ArchCondition<>("depend only on their own service") {
      @Override
      public void check(JavaClass item, ConditionEvents events) {
        String sourceRoot = PackageRoots.of(item.getPackageName());
        if (sourceRoot == null || PackageRoots.isLibrary(sourceRoot)) {
          return;
        }
        for (Dependency dependency : item.getDirectDependenciesFromSelf()) {
          String targetRoot = PackageRoots.of(dependency.getTargetClass().getPackageName());
          if (targetRoot != null
              && !PackageRoots.isLibrary(targetRoot)
              && !targetRoot.equals(sourceRoot)) {
            events.add(
                SimpleConditionEvent.violated(
                    item,
                    "H4 "
                        + item.getFullName()
                        + " depends on "
                        + dependency.getTargetClass().getFullName()
                        + " from another service"));
          }
        }
      }
    };
  }

  private ServiceIsolationRules() {}
}
