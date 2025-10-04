plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.fair_front"
    compileSdk = 35
    ndkVersion = "29.0.13113456"     // NDK 버전 고정

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.fair_front"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 23
        targetSdk = 35
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        getByName("release") {
            isMinifyEnabled = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            // 실제 앱 배포 시에는 signingConfigs에서 release 키를 설정하고 사용
            signingConfig = signingConfigs.getByName("debug")   // 임시 코드
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Flutter 기본 설정 (자동 포함)
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7")

    // Kakao Android SDK 명시적으로 추가
    implementation("com.kakao.sdk:v2-user:2.18.0")

    // Java 8+ core API desugaring 지원 라이브러리
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}

