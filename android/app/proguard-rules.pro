# ── Flutter engine ─────────────────────────────────────────────────────────────
-keep class io.flutter.** { *; }
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

# ── Kotlin coroutines ───────────────────────────────────────────────────────────
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# ── Drift / SQLite ──────────────────────────────────────────────────────────────
# Drift uses reflection to find generated *.drift files; keep generated classes.
-keep class ** implements androidx.sqlite.db.SupportSQLiteOpenHelper$Factory { *; }
-keep class androidx.sqlite.** { *; }
-dontwarn org.jetbrains.annotations.**

# ── Sentry ──────────────────────────────────────────────────────────────────────
-keep class io.sentry.** { *; }
-dontwarn io.sentry.**
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception

# ── OkHttp (used by Supabase Realtime / Dart HTTP) ─────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }

# ── Supabase / Realtime websocket ───────────────────────────────────────────────
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**

# ── Workmanager ─────────────────────────────────────────────────────────────────
-keep class androidx.work.** { *; }
-keep class * extends androidx.work.Worker { *; }
-keep class * extends androidx.work.ListenableWorker {
    public <init>(android.content.Context, androidx.work.WorkerParameters);
}

# ── ML Kit barcode (mobile_scanner) ────────────────────────────────────────────
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

# ── Suppress R8 missing-class warnings from optional MediaPipe protos ──────────
-dontwarn com.google.mediapipe.proto.CalculatorProfileProto$CalculatorProfile
-dontwarn com.google.mediapipe.proto.GraphTemplateProto$CalculatorGraphTemplate

# ── Gson / JSON serialization ────────────────────────────────────────────────────
-keepattributes Signature
-keepattributes Exceptions
-dontwarn sun.misc.**
