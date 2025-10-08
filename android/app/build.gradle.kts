// android/app/build.gradle.kts
import java.util.Properties
import java.io.FileInputStream
import java.io.File

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

// plugins {} 아래
val keyPropsFile = File(rootProject.projectDir, "key.properties")
println("KEY path=${keyPropsFile.absolutePath} exists=${keyPropsFile.exists()}")

val keystoreProperties = Properties().apply {
    if (keyPropsFile.exists()) load(FileInputStream(keyPropsFile))
}

android {
    namespace = "com.princess.ja_chwi"
    compileSdk = 36
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.princess.ja_chwi"
        minSdk = flutter.minSdkVersion
        targetSdk = 35
        // ↓ Flutter의 pubspec 버전 사용
    versionCode = flutter.versionCode.toInt()
    versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String?
            keyPassword = keystoreProperties["keyPassword"] as String?
            storeFile = (keystoreProperties["storeFile"] as String?)?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as String?
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
    kotlinOptions { jvmTarget = "11" }
}

flutter { source = "../.." }
println("==KEYSTORE DEBUG==")
println("file: ${keystoreProperties["storeFile"]}")
println("alias: ${keystoreProperties["keyAlias"]}")
println("pass: ${keystoreProperties["storePassword"]}")
