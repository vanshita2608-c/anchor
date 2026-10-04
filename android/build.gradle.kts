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
}

subprojects {
    val configureAndroid: (Project) -> Unit = { proj ->
        val android = proj.extensions.findByName("android")
        if (android != null) {
            for (method in android.javaClass.methods) {
                if (method.name in listOf("setCompileSdkVersion", "setCompileSdk")) {
                    try {
                        method.invoke(android, 36)
                        break
                    } catch (e: Exception) {
                        try {
                            method.invoke(android, "android-36")
                            break
                        } catch (e2: Exception) {}
                    }
                }
            }
        }
    }

    project.plugins.withId("com.android.library") {
        configureAndroid(project)
    }
    if (project.state.executed) {
        configureAndroid(project)
    } else {
        project.afterEvaluate {
            configureAndroid(project)
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
