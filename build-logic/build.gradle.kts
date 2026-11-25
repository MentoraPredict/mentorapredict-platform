plugins {
    `kotlin-dsl`
}

dependencies {
    // The convention plugins apply these plugins, so they must be on the classpath.
    implementation(libs.spring.boot.gradle.plugin)
    implementation(libs.spotbugs.gradle.plugin)
    implementation(libs.errorprone.gradle.plugin)
    implementation(libs.spotless.gradle.plugin)
}
