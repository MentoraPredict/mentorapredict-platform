package ec.edu.mentora.sample.application.port.in;

/**
 * Command: register (or replace) a sample.
 *
 * @param id identifier of the sample
 * @param nombre name of the sample
 */
public record RegistrarMuestraCommand(String id, String nombre) {}
