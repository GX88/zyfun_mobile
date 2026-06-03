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
        extensions.findByName("android")?.let { extension ->
            val androidExtensionClass = extension.javaClass
            val compileSdkMethod = androidExtensionClass.methods.firstOrNull {
                it.name == "setCompileSdk" &&
                    it.parameterCount == 1 &&
                    (it.parameterTypes[0] == Int::class.javaPrimitiveType ||
                        it.parameterTypes[0] == Integer::class.java)
            }
            val compileSdkVersionMethod = androidExtensionClass.methods.firstOrNull {
                it.name == "setCompileSdkVersion" && it.parameterCount == 1
            }

            when {
                compileSdkMethod != null -> compileSdkMethod.invoke(extension, 36)
                compileSdkVersionMethod != null -> {
                    val parameterType = compileSdkVersionMethod.parameterTypes[0]
                    if (parameterType == String::class.java) {
                        compileSdkVersionMethod.invoke(extension, "android-36")
                    } else {
                        compileSdkVersionMethod.invoke(extension, 36)
                    }
                }
            }
        }

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
