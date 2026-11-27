package ec.edu.mentora.archrules;

import static com.tngtech.archunit.lang.syntax.ArchRuleDefinition.noClasses;

import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

/** Rules H1, H2 and H3: which layer may import which (DOC-CAL-08 section 3). */
public final class LayerRules {

  /**
   * H1: the domain does not import other layers or any framework: Spring, Jakarta (persistence,
   * validation, annotations), Jackson, Hibernate, jOOQ, cloud SDKs or Kafka.
   */
  @ArchTest
  public static final ArchRule H1_DOMAIN_IS_PURE =
      noClasses()
          .that()
          .resideInAPackage("..domain..")
          .should()
          .dependOnClassesThat()
          .resideInAnyPackage(
              "..application..",
              "..infrastructure..",
              "..interfaces..",
              "org.springframework..",
              "jakarta..",
              "com.fasterxml.jackson..",
              "tools.jackson..",
              "org.hibernate..",
              "org.jooq..",
              "software.amazon..",
              "org.apache.kafka..")
          .allowEmptyShould(true)
          .as("H1 domain must not depend on other layers or frameworks");

  /** H2: the application layer does not import adapters. */
  @ArchTest
  public static final ArchRule H2_APPLICATION_DOES_NOT_USE_ADAPTERS =
      noClasses()
          .that()
          .resideInAPackage("..application..")
          .should()
          .dependOnClassesThat()
          .resideInAnyPackage("..infrastructure..", "..interfaces..")
          .allowEmptyShould(true)
          .as("H2 application must not depend on adapters");

  /** H3: output adapters do not import input adapters. */
  @ArchTest
  public static final ArchRule H3_INFRASTRUCTURE_DOES_NOT_USE_INTERFACES =
      noClasses()
          .that()
          .resideInAPackage("..infrastructure..")
          .should()
          .dependOnClassesThat()
          .resideInAPackage("..interfaces..")
          .allowEmptyShould(true)
          .as("H3 infrastructure must not depend on interfaces");

  /** H3: input adapters do not import output adapters. */
  @ArchTest
  public static final ArchRule H3_INTERFACES_DO_NOT_USE_INFRASTRUCTURE =
      noClasses()
          .that()
          .resideInAPackage("..interfaces..")
          .should()
          .dependOnClassesThat()
          .resideInAPackage("..infrastructure..")
          .allowEmptyShould(true)
          .as("H3 interfaces must not depend on infrastructure");

  private LayerRules() {}
}
