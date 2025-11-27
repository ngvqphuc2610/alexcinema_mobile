allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")

    // Ensure flutter_zalopay_sdk has a namespace (required by AGP 8+)
    plugins.withId("com.android.library") {
        val androidExt = extensions.findByName("android")
        if (androidExt is com.android.build.gradle.LibraryExtension && androidExt.namespace == null) {
            when (project.name) {
                // Keep namespace aligned with plugin code package (for R.java)
                "flutter_zalopay_sdk" -> androidExt.namespace = "com.flutterzalopay.flutter_zalo_sdk"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
