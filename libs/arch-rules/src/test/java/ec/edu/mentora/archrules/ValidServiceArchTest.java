package ec.edu.mentora.archrules;

import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.junit.ArchTests;

/** A well-formed service passes every rule, using the same three lines as a real service. */
@AnalyzeClasses(packages = "ec.edu.mentora.fixturevalid")
class ValidServiceArchTest {

  @ArchTest static final ArchTests hexagonal = ArchTests.in(HexagonalRules.class);
}
