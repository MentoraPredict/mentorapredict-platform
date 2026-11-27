plugins {
    id("mentora.biblioteca")
}

dependencies {
    // Services write their architecture test against these rules, so ArchUnit travels with them.
    api(libs.archunit)

    // Only the fixtures of the violation tests use these (to prove H1 rejects them in the domain).
    testImplementation("org.springframework:spring-context")
    testImplementation("jakarta.annotation:jakarta.annotation-api")
    testImplementation("com.fasterxml.jackson.core:jackson-annotations")
    testImplementation(project(":libs:platform"))
}
