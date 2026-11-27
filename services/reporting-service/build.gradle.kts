plugins {
    id("mentora.servicio")
}

dependencies {
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation(project(":libs:platform"))
    testImplementation(project(":libs:arch-rules"))
    testImplementation(project(":libs:testing"))
}
