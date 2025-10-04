# Kakao Map SDK 예외 처리
-keep class net.daum.mf.** { *; }
-dontwarn net.daum.mf.**

# Kakao Login, User, Talk SDK 예외 처리
-keep class com.kakao.** { *; }
-dontwarn com.kakao.**
-keep class com.kakao.sdk.auth.AuthCodeHandlerActivity { *; }
-keepattributes Signature
-keepattributes *Annotation*

# BouncyCastle 예외
-dontwarn org.bouncycastle.**
-keep class org.bouncycastle.** { *; }

# Conscrypt 예외
-dontwarn org.conscrypt.**
-keep class org.conscrypt.** { *; }

# OpenJSSE 예외
-dontwarn org.openjsse.**
-keep class org.openjsse.** { *; }
