// android/build.gradle.kts

buildscript {
  repositories {
    google()
    mavenCentral()
  }
  dependencies {
    // Android Gradle plugin
    classpath("com.android.tools.build:gradle:7.4.0")
    // Google services / Firebase plugin
    classpath("com.google.gms:google-services:4.3.15")
  }
}

allprojects {
  repositories {
    google()
    mavenCentral()
  }
}

// Optional: redirect build outputs
//val newBuildDir = rootProject.layout.buildDirectory.dir("../../build").get()
//rootProject.layout.buildDirectory.set(newBuildDir)
//
//subprojects {
//  val subBuild = newBuildDir.dir(project.name)
//  project.layout.buildDirectory.set(subBuild)
//  evaluationDependsOn(":app")
//}
//
//tasks.register<Delete>("clean") {
//  delete(rootProject.layout.buildDirectory)
//}