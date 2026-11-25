// Common Java and quality configuration shared by services and libraries (DOC-CAL-08 section 2.1):
// Java 21 toolchain, -Xlint:all -Werror, Error Prone with NullAway, Spotless (google-java-format),
// JUnit 5, JaCoCo, Checkstyle, SpotBugs and rule H4.

import net.ltgt.gradle.errorprone.errorprone

plugins {
    java
    jacoco
    checkstyle
    id("com.github.spotbugs")
    id("net.ltgt.errorprone")
    id("com.diffplug.spotless")
}

val libs = the<VersionCatalogsExtension>().named("libs")

repositories {
    mavenCentral()
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(libs.findVersion("java").get().requiredVersion.toInt())
    }
}

dependencies {
    errorprone(libs.findLibrary("errorprone-core").get())
    errorprone(libs.findLibrary("nullaway").get())
    // Packages are annotated @NullMarked (JSpecify); the annotation is only needed to compile.
    compileOnly(libs.findLibrary("jspecify").get())
    testCompileOnly(libs.findLibrary("jspecify").get())
}

tasks.withType<JavaCompile>().configureEach {
    options.encoding = "UTF-8"
    options.compilerArgs.addAll(listOf("-parameters", "-Xlint:all", "-Werror"))
    options.errorprone {
        // Generated code (OpenAPI interfaces, Avro, jOOQ) is not ours to fix.
        disableWarningsInGeneratedCode = true
        excludedPaths = ".*/build/generated/.*"
        // Null safety is enforced only in packages marked @NullMarked.
        error("NullAway")
        option("NullAway:OnlyNullMarked", "true")
    }
}

tasks.withType<Test>().configureEach {
    useJUnitPlatform()
    finalizedBy(tasks.named("jacocoTestReport"))
}

jacoco {
    toolVersion = libs.findVersion("jacoco").get().requiredVersion
}

tasks.withType<JacocoReport>().configureEach {
    reports {
        xml.required = true
        html.required = true
    }
}

checkstyle {
    toolVersion = libs.findVersion("checkstyle").get().requiredVersion
    configFile = rootProject.file("config/checkstyle/checkstyle.xml")
    isIgnoreFailures = false
    maxWarnings = 0
}

spotbugs {
    ignoreFailures = false
}

spotless {
    java {
        target("src/**/*.java")
        targetExclude("build/generated/**")
        googleJavaFormat(libs.findVersion("google-java-format").get().requiredVersion)
    }
}

// Rule H4: a service or library never depends on code of a service.
// Only libs/* and generated contracts are allowed. The check runs after the
// project is evaluated, so the build fails at configuration time.
afterEvaluate {
    configurations.forEach { configuration ->
        configuration.dependencies.withType<ProjectDependency>().forEach { dependency ->
            val target = dependency.path
            val isService = target.startsWith(":services:")
            if (isService && target != project.path) {
                throw GradleException(
                    "Rule H4 violated: ${project.path} depends on $target through '${configuration.name}'. " +
                        "A service can only depend on libs/*, never on another service."
                )
            }
        }
    }
}
