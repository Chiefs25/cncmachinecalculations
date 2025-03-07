plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin") // Flutter plugin should be applied first
    id("kotlin-android")
}

android {
    namespace = "com.example.cncmachinecalculations"
    compileSdk = 34

    ndkVersion = "27.0.12077973"  // Explicitly setting NDK version

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"  // Ensuring proper JVM target
    }

    defaultConfig {
        applicationId = "com.example.cncmachinecalculations"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
        multiDexEnabled = true
    }

    buildTypes {
        release {
            isMinifyEnabled = true  // Enables code shrinking, obfuscation
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                file("proguard-rules.pro") // Ensures correct reference
            )
        }
    }

    buildFeatures {
        viewBinding = true  // ✅ Correct syntax for Kotlin DSL
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.appcompat:appcompat:1.6.1")
    implementation("androidx.multidex:multidex:2.0.1")  // Ensure MultiDex dependency is added
}
