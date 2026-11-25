plugins {
    id("mentora.servicio")
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-webmvc")

    // A service may depend on libs/* only (rule H4).
    testImplementation(project(":libs:arch-rules"))
    testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
}
