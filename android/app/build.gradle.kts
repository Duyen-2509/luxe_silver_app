plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.luxe_silver_app"
    compileSdk = 35
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        //jvmTarget = JavaVersion.VERSION_11.toString()
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.luxe_silver_app"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-analytics-ktx:22.4.0")
    implementation("org.jetbrains.kotlin:kotlin-stdlib")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
    // Khai báo thư viện emoji2 cần thiết
    implementation("androidx.emoji2:emoji2:1.3.0")

    // Để dùng các hàm Java 8+
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
