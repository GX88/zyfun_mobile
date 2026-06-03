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
    afterEvaluate {
        if (name == "fijkplayer") {
            extensions.findByName("android")?.let { extension ->
                val androidExtensionClass = extension.javaClass
                val namespaceMethod = androidExtensionClass.methods.firstOrNull {
                    it.name == "setNamespace" && it.parameterCount == 1
                }
                namespaceMethod?.invoke(extension, "com.befovy.fijkplayer")
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
