package ec.edu.mentora.archrules;

import org.jspecify.annotations.Nullable;

final class PackageRoots {

  private static final String PREFIX = "ec.edu.mentora.";

  private PackageRoots() {}

  @Nullable
  static String of(String packageName) {
    if (!packageName.startsWith(PREFIX)) {
      return null;
    }
    String rest = packageName.substring(PREFIX.length());
    int dot = rest.indexOf('.');
    return dot < 0 ? rest : rest.substring(0, dot);
  }

  static boolean isLibrary(String root) {
    return "platform".equals(root)
        || "archrules".equals(root)
        || "testing".equals(root)
        || "contracts".equals(root);
  }
}
