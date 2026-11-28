package ec.edu.mentora.archrules;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import com.tngtech.archunit.lang.ArchRule;

/** Loads the fixture services used to prove that every rule can fail. */
final class Fixtures {

  private static final String VIOLATIONS = "ec.edu.mentora.fixtureviolations";
  private static final String VALID = "ec.edu.mentora.fixturevalid";

  /** Checks that the rule fails on the violating service and names every expected piece. */
  static void assertRuleFails(ArchRule rule, String... expectedInReport) {
    JavaClasses classes = new ClassFileImporter().importPackages(VIOLATIONS, VALID);
    assertThatThrownBy(() -> rule.check(classes))
        .isInstanceOf(AssertionError.class)
        .hasMessageContainingAll(expectedInReport);
  }

  private Fixtures() {}
}
