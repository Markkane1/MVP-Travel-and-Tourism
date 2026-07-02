plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// ---------------------------------------------------------------------------
// Read signing credentials from key.properties (gitignored)
// ---------------------------------------------------------------------------
import java.util.Properties
import java.io.FileInputStream

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(FileInputStream(keyPropertiesFile))
}

android {
    namespace = "com.mvptravelandtourism.app"
    compileSdk = flutter.compileSdkVersion

    buildFeatures {
        resValues = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    // ---------------------------------------------------------------------------
    // Signing configurations
    // ---------------------------------------------------------------------------
    signingConfigs {
        create("release") {
            keyAlias = keyProperties.getProperty("keyAlias") ?: ""
            keyPassword = keyProperties.getProperty("keyPassword") ?: ""
            storeFile = keyProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keyProperties.getProperty("storePassword") ?: ""
        }
    }

    defaultConfig {
        applicationId = "com.mvptravelandtourism.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ---------------------------------------------------------------------------
    // Product flavors: dev (side-by-side) and prod (clean ID)
    // ---------------------------------------------------------------------------
    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
            applicationIdSuffix = ".dev"
            versionNameSuffix = "-dev"
            resValue("string", "app_name", "MVP Travel DEV")
        }
        create("prod") {
            dimension = "environment"
            // No suffix — uses the base applicationId: com.mvptravelandtourism.app
            resValue("string", "app_name", "MVP Travel")
        }
    }

    buildTypes {
        debug {
            // dev flavor uses debug signing by default
        }
        release {
            // Use release signing config when key.properties is present
            signingConfig = if (keyPropertiesFile.exists()) {
                signingConfigs.getByName("release")
            } else {
                // Fallback: debug keys allow `flutter run --release` without keystore
                // Replace this before submitting to Play Store
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
