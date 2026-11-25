package ec.edu.mentora.archrules;

import org.junit.jupiter.api.Test;

/** H1, H2 and H3 fail when a layer imports what it must not. */
class LayerViolationsTest {

  private static final String ROOT = "ec.edu.mentora.fixtureviolations.";

  @Test
  void h1RejectsADomainThatDependsOnTheApplicationLayer() {
    Fixtures.assertRuleFails(LayerRules.H1_DOMAIN_IS_PURE, ROOT + "domain.UsesApplication");
  }

  @Test
  void h1RejectsADomainThatDependsOnSpring() {
    Fixtures.assertRuleFails(
        LayerRules.H1_DOMAIN_IS_PURE, ROOT + "domain.UsesSpring", "org.springframework");
  }

  @Test
  void h1RejectsADomainThatDependsOnJakarta() {
    Fixtures.assertRuleFails(
        LayerRules.H1_DOMAIN_IS_PURE, ROOT + "domain.UsesJakarta", "jakarta.annotation");
  }

  @Test
  void h1RejectsADomainThatDependsOnJackson() {
    Fixtures.assertRuleFails(
        LayerRules.H1_DOMAIN_IS_PURE, ROOT + "domain.UsesJackson", "com.fasterxml.jackson");
  }

  @Test
  void h2RejectsAnApplicationLayerThatDependsOnAnAdapter() {
    Fixtures.assertRuleFails(
        LayerRules.H2_APPLICATION_DOES_NOT_USE_ADAPTERS, ROOT + "application.Handler");
  }

  @Test
  void h3RejectsAnOutputAdapterThatDependsOnAnInputAdapter() {
    Fixtures.assertRuleFails(
        LayerRules.H3_INFRASTRUCTURE_DOES_NOT_USE_INTERFACES,
        ROOT + "infrastructure.UsesInterfaces");
  }

  @Test
  void h3RejectsAnInputAdapterThatDependsOnAnOutputAdapter() {
    Fixtures.assertRuleFails(
        LayerRules.H3_INTERFACES_DO_NOT_USE_INFRASTRUCTURE, ROOT + "interfaces.UsesInfrastructure");
  }
}
