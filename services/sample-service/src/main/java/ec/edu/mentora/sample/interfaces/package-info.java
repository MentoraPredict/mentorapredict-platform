/**
 * Interfaces: input adapters (REST controllers, error translation, scheduled tasks).
 *
 * <p>It imports the application and domain layers, never the output adapters (rule H3). Request and
 * response objects live here, so the domain carries no JSON annotations (rule H1).
 */
@NullMarked
package ec.edu.mentora.sample.interfaces;

import org.jspecify.annotations.NullMarked;
