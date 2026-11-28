package ec.edu.mentora.archrules;

import static org.assertj.core.api.Assertions.assertThatThrownBy;

import com.tngtech.archunit.core.domain.JavaClasses;
import com.tngtech.archunit.core.importer.ClassFileImporter;
import org.junit.jupiter.api.Test;

class LibraryRulesTest {

  @Test
  void h5RejectsALibraryThatDependsOnAService() {
    JavaClasses classes =
        new ClassFileImporter()
            .importPackages("ec.edu.mentora.platform.fixture", "ec.edu.mentora.fixturevalid");

    assertThatThrownBy(() -> LibraryRules.H5_LIBRARIES_DO_NOT_DEPEND_ON_SERVICES.check(classes))
        .isInstanceOf(AssertionError.class)
        .hasMessageContaining("H5");
  }
}
