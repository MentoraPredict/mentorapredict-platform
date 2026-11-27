package ec.edu.mentora.archrules;

import com.tngtech.archunit.core.importer.ImportOption;
import com.tngtech.archunit.junit.AnalyzeClasses;
import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.lang.ArchRule;

@AnalyzeClasses(
    packages = {"ec.edu.mentora.platform", "ec.edu.mentora.testing", "ec.edu.mentora.archrules"},
    importOptions = ImportOption.DoNotIncludeTests.class)
class LibraryArchTest {

  @ArchTest static final ArchRule h5 = LibraryRules.H5_LIBRARIES_DO_NOT_DEPEND_ON_SERVICES;
}
