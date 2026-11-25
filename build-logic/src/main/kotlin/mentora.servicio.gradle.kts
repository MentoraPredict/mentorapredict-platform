// Convention for every microservice under services/*.
// Applies Java 21, Spring Boot (BOM and executable jar), the test stack and the
// quality tools. Dependencies between services are rejected (rule H4).

import org.springframework.boot.gradle.plugin.SpringBootPlugin

plugins {
    id("mentora.calidad")
    id("org.springframework.boot")
}

val libs = the<VersionCatalogsExtension>().named("libs")

dependencies {
    // Spring Boot manages the versions of its own starters and libraries.
    implementation(platform(SpringBootPlugin.BOM_COORDINATES))
    testImplementation(platform(libs.findLibrary("testcontainers-bom").get()))

    testImplementation("org.springframework.boot:spring-boot-starter-test")
    testImplementation(libs.findLibrary("archunit").get())
    testRuntimeOnly("org.junit.platform:junit-platform-launcher")
}
