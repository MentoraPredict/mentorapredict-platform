package ec.edu.mentora.archrules;

import org.junit.jupiter.api.Test;

class BoundaryViolationsTest {

  @Test
  void h4RejectsAServiceThatDependsOnAnotherService() {
    Fixtures.assertRuleFails(
        ServiceIsolationRules.H4_SERVICES_DO_NOT_DEPEND_ON_OTHER_SERVICES,
        "H4",
        "UsesOtherService");
  }

  @Test
  void h6RejectsSqlOutsideInfrastructure() {
    Fixtures.assertRuleFails(AdapterRules.H6_SQL_ONLY_IN_INFRASTRUCTURE, "H6", "UsesSql");
  }

  @Test
  void h7RejectsARepositoryWithoutTheTenantContext() {
    Fixtures.assertRuleFails(
        AdapterRules.H7_REPOSITORIES_USE_THE_TENANT_CONTEXT, "H7", "OrderRepository");
  }

  @Test
  void h9RejectsDirectOutboxUseFromTheDomain() {
    Fixtures.assertRuleFails(AdapterRules.H9_EVENTS_GO_THROUGH_THE_OUTBOX, "H9", "UsesOutbox");
  }
}
