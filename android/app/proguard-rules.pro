-keepattributes Signature
-keepattributes *Annotation*

# Gson TypeToken needs generic signatures kept (R8/ProGuard).
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class com.google.gson.** { *; }

# Keep flutter_local_notifications implementation.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

