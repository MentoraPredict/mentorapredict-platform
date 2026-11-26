plugins {
    id("mentora.servicio")
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-webmvc")

    // A service may depend on libs/* only (rule H4).
    testImplementation(project(":libs:arch-rules"))
    testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")

    // The integration tests (./gradlew integrationTest) use PostgreSQL and Kafka. These clients are
    // only on their classpath for now; they move to `implementation` with MPC-115 and MPC-116.
    "integrationTestImplementation"("org.springframework.boot:spring-boot-starter-jdbc")
    "integrationTestImplementation"("org.springframework.boot:spring-boot-starter-kafka")
    "integrationTestRuntimeOnly"("org.postgresql:postgresql")
}
