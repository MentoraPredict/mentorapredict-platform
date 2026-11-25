package ec.edu.mentora.archrules;

import org.junit.jupiter.api.Test;

/** H8, H10 and the package layout fail when they are broken on purpose. */
class OtherViolationsTest {

  @Test
  void h8RejectsACycleBetweenTheApplicationAndInfrastructureLayers() {
    Fixtures.assertRuleFails(CycleRules.H8_LAYERS_HAVE_NO_CYCLES, "Cycle detected");
  }

  @Test
  void h10RejectsDirectCallsToTheClockAndToRandomSources() {
    Fixtures.assertRuleFails(
        DeterminismRules.H10_DOMAIN_HAS_NO_CLOCK_OR_RANDOM,
        "Instant.now()",
        "LocalDate.now(",
        "System.currentTimeMillis()",
        "UUID.randomUUID()",
        "Math.random()");
  }

  @Test
  void theLayoutRejectsAPackageThatIsNotOneOfTheFourLayers() {
    Fixtures.assertRuleFails(
        StructureRules.ONLY_THE_FOUR_LAYERS, "ec.edu.mentora.fixtureviolations.util.Helper");
  }
}
