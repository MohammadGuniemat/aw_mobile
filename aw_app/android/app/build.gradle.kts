plugins {
    id("com.android.application")
    id("kotlin-android")
    // Flutter Gradle plugin must be applied last
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aw_app"
    compileSdk = 34  // Latest stable compileSdk

    // ✅ Use NDK version required by your plugins
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.aw_app"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            // Signing config; replace with your release keystore if needed
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
        }
        debug {
            isMinifyEnabled = false
        }
    }
}

flutter {
    source = "../.."
}
