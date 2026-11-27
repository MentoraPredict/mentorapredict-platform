plugins {
    id("mentora.servicio")
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springframework.boot:spring-boot-starter-actuator")

    testImplementation(project(":libs:arch-rules"))
    testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
}
