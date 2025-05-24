// android/app/build.gradle.kts
plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
    // Note: Do NOT include com.google.gms.google-services here
}

android {
    namespace = "com.example.budget_wise"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.example.budget_wise"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        getByName("debug") {
            isDebuggable = true
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// Dependencies should be outside android {}
dependencies {
    implementation("com.google.firebase:firebase-auth-ktx:22.1.1")
    implementation("com.google.firebase:firebase-firestore-ktx:24.7.0")
}

flutter {
    source = "../.."
}

// Apply the Google services Gradle plugin to process `google-services.json`
// Apply the Google Services plugin to process google-services.json
apply(plugin = "com.google.gms.google-services")
