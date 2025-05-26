# Kakao Map SDK 예외 처리
-keep class net.daum.mf.** { *; }
-dontwarn net.daum.mf.**

# Kakao Login, User, Talk SDK 예외 처리
-keep class com.kakao.** { *; }
-dontwarn com.kakao.**
-keep class com.kakao.sdk.auth.AuthCodeHandlerActivity { *; }
-keepattributes Signature
-keepattributes *Annotation*
