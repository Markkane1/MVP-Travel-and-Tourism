plugins {
    id("com.android.application")
    // START: FlutterFire Configuration
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    // END: FlutterFire Configuration
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
val googleMapsApiKey =
    (project.findProperty("GOOGLE_MAPS_API_KEY") as? String)
        ?: System.getenv("GOOGLE_MAPS_API_KEY")
        ?: ""

android {
    namespace = "com.mvptravelandtourism.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

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
        manifestPlaceholders["GOOGLE_MAPS_API_KEY"] = googleMapsApiKey
    }

    // ---------------------------------------------------------------------------
    // Product flavors: dev (side-by-side) and prod (clean ID)
    // ---------------------------------------------------------------------------
    flavorDimensions += "environment"

    productFlavors {
        create("dev") {
            dimension = "environment"
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
                val isProdRelease = gradle.startParameter.taskNames.any {
                    it.contains("ProdRelease", ignoreCase = true)
                }
                if (isProdRelease) {
                    throw org.gradle.api.GradleException(
                        "Prod release builds require android/key.properties and a release keystore."
                    )
                }
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
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
