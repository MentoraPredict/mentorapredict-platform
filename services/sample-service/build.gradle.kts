plugins {
    id("mentora.servicio")
    alias(libs.plugins.openapi.generator)
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    // Validates the requests with the constraints of the OpenAPI contract.
    implementation("org.springframework.boot:spring-boot-starter-validation")
    // Health checks for the platform (liveness and readiness).
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    // PostgreSQL, with Flyway applying the migrations of src/main/resources/db/migration at startup.
    implementation("org.springframework.boot:spring-boot-starter-jdbc")
    implementation("org.springframework.boot:spring-boot-starter-flyway")
    runtimeOnly("org.flywaydb:flyway-database-postgresql")
    runtimeOnly("org.postgresql:postgresql")

    // A service may depend on libs/* only (rule H4).
    testImplementation(project(":libs:arch-rules"))
    testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")

    // The integration tests (./gradlew integrationTest) also use Kafka. Its client is only on their
    // classpath: move it to `implementation` when the service uses Kafka.
    "integrationTestImplementation"("org.springframework.boot:spring-boot-starter-kafka")
}

// Contract first: the server interfaces and DTOs are generated from the contract of this service.
val generatedOpenApi = layout.buildDirectory.dir("generated/openapi")
val contract = rootProject.file("libs/contracts/openapi/sample-service.yaml")

openApiGenerate {
    generatorName = "spring"
    // Passed as a file URI: with a plain path, resolving the $ref of an OpenAPI 3.1 contract fails
    // when a folder name has spaces.
    remoteInputSpec = contract.toURI().toString()
    outputDir = generatedOpenApi
    apiPackage = "ec.edu.mentora.sample.interfaces.rest.api"
    modelPackage = "ec.edu.mentora.sample.interfaces.rest.model"
    cleanupOutput = true
    // Only interfaces and models, no supporting files.
    globalProperties = mapOf("apis" to "", "models" to "")
    configOptions =
        mapOf(
            "interfaceOnly" to "true",
            "skipDefaultInterface" to "true",
            "useResponseEntity" to "false",
            "useSpringBoot4" to "true",
            "useJackson3" to "true",
            // Nullability with JSpecify, as in our code; Spring's own annotation is deprecated.
            "useJspecify" to "true",
            "useBeanValidation" to "true",
            "useTags" to "true",
            "openApiNullable" to "false",
            "documentationProvider" to "none",
            "annotationLibrary" to "none",
            "hideGenerationTimestamp" to "true",
        )
}

sourceSets.main {
    java.srcDir(generatedOpenApi.map { it.dir("src/main/java") })
}

// With a URI the plugin does not watch the file, so it is declared here: editing the contract
// generates the code again.
tasks.named("openApiGenerate") { inputs.file(contract) }

tasks.named("compileJava") { dependsOn(tasks.named("openApiGenerate")) }

// The quality tools check our code, not the generated one.
tasks.withType<Checkstyle>().configureEach {
    exclude { it.file.invariantSeparatorsPath.contains("/build/generated/") }
}

spotbugs {
    excludeFilter = rootProject.file("config/spotbugs/generated-exclude.xml")
}
