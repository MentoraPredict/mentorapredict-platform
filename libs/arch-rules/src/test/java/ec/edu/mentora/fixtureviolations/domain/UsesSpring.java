package ec.edu.mentora.fixtureviolations.domain;

import org.springframework.stereotype.Component;

/** Fixture, violates H1: the domain depends on Spring. */
@Component
public final class UsesSpring {}
