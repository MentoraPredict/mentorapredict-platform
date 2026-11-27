package ec.edu.mentora.idn;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.junit.ArchTests;
import ec.edu.mentora.archrules.HexagonalRules;

/** Checks the shared hexagonal architecture rules. */
@AnalyzeClasses(
    packages = "ec.edu.mentora.idn",
    importOptions = ImportOption.DoNotIncludeTests.class)
class ArquitecturaHexagonalTest {
  @ArchTest static final ArchTests hexagonal = ArchTests.in(HexagonalRules.class);
}
