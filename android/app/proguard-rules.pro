# OkHttp / Conscrypt / OpenJSSE (R8 missing class 오류 방지)
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**
-dontwarn org.conscrypt.**
-dontwarn org.openjsse.**

# Google Play Core (Flutter deferred components)
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Flutter / General
-keep class io.flutter.** { *; }
-keep class com.google.** { *; }

# Glance AppWidget - 릴리스 빌드에서 위젯 클래스가 제거/난독화되지 않도록 보호
-keep class androidx.glance.** { *; }
-keep class * extends androidx.glance.appwidget.GlanceAppWidget { *; }
-keep class * extends androidx.glance.appwidget.GlanceAppWidgetReceiver { *; }
-keep class com.bebetap.app.glance.** { *; }

# UCrop (image_cropper 내부 라이브러리) - R8 난독화로 Activity 제거 방지
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**
