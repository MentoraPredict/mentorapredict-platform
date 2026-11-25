package ec.edu.mentora.fixtureviolations.domain;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

/** Fixture, violates H1: the domain depends on Jackson. */
@JsonIgnoreProperties(ignoreUnknown = true)
public final class UsesJackson {}
