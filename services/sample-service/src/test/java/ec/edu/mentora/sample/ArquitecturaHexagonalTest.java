package ec.edu.mentora.sample;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.junit.ArchTests;
import ec.edu.mentora.archrules.HexagonalRules;

/** Architecture rules H1, H2, H3, H8 and H10 plus the package layout (DOC-CAL-08 section 3). */
@AnalyzeClasses(
    packages = "ec.edu.mentora.sample",
    importOptions = ImportOption.DoNotIncludeTests.class)
class ArquitecturaHexagonalTest {

  @ArchTest static final ArchTests hexagonal = ArchTests.in(HexagonalRules.class);
}
