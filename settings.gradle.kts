pluginManagement {
    // Convention plugins (mentora.servicio, mentora.biblioteca) live in build-logic.
    includeBuild("build-logic")
}

rootProject.name = "mentorapredict-services"

// Every folder under services/ and libs/ that has a build.gradle.kts becomes a
// Gradle subproject automatically, so adding a service does not touch this file.
// services/grading-service -> :services:grading-service
// libs/contracts           -> :libs:contracts
listOf("services", "libs").forEach { group ->
    file(group).listFiles { dir -> dir.isDirectory }?.sorted()?.forEach { dir ->
        if (file("${dir.path}/build.gradle.kts").exists()) {
            include(":$group:${dir.name}")
        }
    }
}
