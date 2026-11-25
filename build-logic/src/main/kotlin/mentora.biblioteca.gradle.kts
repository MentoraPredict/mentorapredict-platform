import org.springframework.boot.gradle.plugin.SpringBootPlugin

// Convention for shared libraries under libs/*.
// A library is a plain Java library: no Spring Boot executable, no business logic (rule H5).

plugins {
    `java-library`
    id("mentora.calidad")
}

val libs = the<VersionCatalogsExtension>().named("libs")

dependencies {
    // Only the BOM is used for versions; the library does not become a Spring Boot application.
    testImplementation(platform(SpringBootPlugin.BOM_COORDINATES))
    testImplementation(platform(libs.findLibrary("testcontainers-bom").get()))
    testImplementation("org.junit.jupiter:junit-jupiter")
    testImplementation("org.assertj:assertj-core")
    testImplementation(libs.findLibrary("archunit").get())
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}
