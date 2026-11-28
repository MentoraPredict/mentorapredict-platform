package ec.edu.mentora.archrules;

import com.tngtech.archunit.junit.ArchTest;
import com.tngtech.archunit.junit.ArchTests;

/**
 * Every architecture rule of a service. A service reuses all of them with:
 *
 * <pre>{@code
 * @AnalyzeClasses(
 *     packages = "ec.edu.mentora.<svc>",
 *     importOptions = ImportOption.DoNotIncludeTests.class)
 * class ArquitecturaHexagonalTest {
 *   @ArchTest
 *   static final ArchTests hexagonal = ArchTests.in(HexagonalRules.class);
 * }
 * }</pre>
 */
public final class HexagonalRules {

  /** H1, H2 and H3. */
  @ArchTest public static final ArchTests LAYERS = ArchTests.in(LayerRules.class);

  /** H4. */
  @ArchTest
  public static final ArchTests SERVICE_ISOLATION = ArchTests.in(ServiceIsolationRules.class);

  /** H5. */
  @ArchTest public static final ArchTests LIBRARIES = ArchTests.in(LibraryRules.class);

  /** H6, H7 and H9. */
  @ArchTest public static final ArchTests ADAPTERS = ArchTests.in(AdapterRules.class);

  /** H8. */
  @ArchTest public static final ArchTests CYCLES = ArchTests.in(CycleRules.class);

  /** H10. */
  @ArchTest public static final ArchTests DETERMINISM = ArchTests.in(DeterminismRules.class);

  /** Package layout. */
  @ArchTest public static final ArchTests STRUCTURE = ArchTests.in(StructureRules.class);

  private HexagonalRules() {}
}
