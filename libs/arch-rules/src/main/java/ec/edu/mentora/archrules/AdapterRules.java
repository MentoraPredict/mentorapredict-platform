package ec.edu.mentora.archrules;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.classes;
import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.base.DescribedPredicate;
import com.tngtech.archunit.core.domain.JavaClass;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

public final class AdapterRules {

  @ArchTest
  public static final ArchRule H6_SQL_ONLY_IN_INFRASTRUCTURE =
      noClasses()
          .that()
          .resideInAnyPackage("..domain..", "..application..", "..interfaces..")
          .should()
          .dependOnClassesThat()
          .resideInAnyPackage("java.sql..", "javax.sql..", "org.jooq..")
          .allowEmptyShould(true)
          .as("H6 SQL and database access must stay in infrastructure adapters");

  @ArchTest
  public static final ArchRule H7_REPOSITORIES_USE_THE_TENANT_CONTEXT =
      classes()
          .that(areSqlRepositories())
          .should()
          .dependOnClassesThat()
          .haveFullyQualifiedName("ec.edu.mentora.platform.tenant.TenantContext")
          .allowEmptyShould(true)
          .as("H7 repository adapters must resolve tenant_id through TenantContext");

  @ArchTest
  public static final ArchRule H9_EVENTS_GO_THROUGH_THE_OUTBOX =
      noClasses()
          .that()
          .resideInAnyPackage("..domain..", "..application..")
          .should()
          .dependOnClassesThat()
          .resideInAnyPackage("org.apache.kafka..", "..outbox..")
          .allowEmptyShould(true)
          .as("H9 domain events must be published through the transactional outbox");

  private static DescribedPredicate<JavaClass> areSqlRepositories() {
    return DescribedPredicate.describe(
        "are repositories that access SQL",
        javaClass ->
            javaClass.getPackageName().contains(".infrastructure")
                && javaClass.getSimpleName().endsWith("Repository")
                && javaClass.getDirectDependenciesFromSelf().stream()
                    .anyMatch(dependency -> accessesSql(dependency.getTargetClass())));
  }

  private static boolean accessesSql(JavaClass target) {
    String packageName = target.getPackageName();
    return isPackage(packageName, "java.sql")
        || isPackage(packageName, "javax.sql")
        || isPackage(packageName, "org.jooq");
  }

  private static boolean isPackage(String packageName, String root) {
    return packageName.equals(root) || packageName.startsWith(root + ".");
  }

  private AdapterRules() {}
}
