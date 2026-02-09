# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Supabase classes
-keep class com.supabase.** { *; }
-dontwarn com.supabase.**

# Keep Riverpod classes
-keep class io.flutter.plugins.riverpod.** { *; }
-dontwarn io.flutter.plugins.riverpod.**

# Keep GoRouter classes
-keep class go_router.** { *; }
-dontwarn go_router.**

# Keep RevenueCat classes (if used)
-keep class com.revenuecat.** { *; }
-dontwarn com.revenuecat.**

# Keep Drift/SQLite classes
-keep class drift.** { *; }
-keep class sqlite3.** { *; }
-dontwarn drift.**
-dontwarn sqlite3.**

# Keep model classes (adjust package name as needed)
-keep class skrolz_app.features.** { *; }
-keep class skrolz_app.data.** { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Flutter deferred components (Play Core) - optional; don't fail if missing
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# Remove logging in release
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
