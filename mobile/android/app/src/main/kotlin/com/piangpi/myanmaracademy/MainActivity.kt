package com.piangpi.myanmaracademy

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONObject

class MainActivity : FlutterActivity() {
    private var permissionResult: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.platformViewsController.registry.registerViewFactory(
            "academy/restricted-web-preview",
            RestrictedPreviewFactory(flutterEngine.dartExecutor.binaryMessenger),
        )
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "academy/reminders")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "requestPermission" -> requestNotificationPermission(result)
                    "schedule" -> try {
                        val values = call.arguments as? Map<*, *>
                            ?: throw IllegalArgumentException("Reminder settings missing")
                        val config = JSONObject()
                        config.put("enabled", values["enabled"] as? Boolean ?: false)
                        config.put("hour", (values["hour"] as? Number)?.toInt() ?: -1)
                        config.put("minute", (values["minute"] as? Number)?.toInt() ?: -1)
                        config.put("study_minutes", (values["study_minutes"] as? Number)?.toInt() ?: 15)
                        config.put("review_enabled", values["review_enabled"] as? Boolean ?: false)
                        config.put("english", values["english"] as? Boolean ?: false)
                        val weekdays = values["weekdays"] as? List<*>
                            ?: throw IllegalArgumentException("Reminder weekdays missing")
                        config.put("weekdays", weekdays.filterIsInstance<Number>().map { it.toInt() })
                        if (!config.getBoolean("enabled") ||
                            config.getInt("hour") !in 0..23 ||
                            config.getInt("minute") !in 0..59 ||
                            config.getJSONArray("weekdays").length() == 0
                        ) throw IllegalArgumentException("Invalid reminder settings")
                        StudyReminderScheduler.schedule(this, config)
                        result.success(null)
                    } catch (_: Exception) {
                        result.error("REMINDER_SCHEDULE_FAILED", "Could not schedule reminders", null)
                    }
                    "cancel" -> {
                        StudyReminderScheduler.cancel(this)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun requestNotificationPermission(result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < 33 ||
            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) ==
            PackageManager.PERMISSION_GRANTED
        ) {
            result.success(true)
            return
        }
        if (permissionResult != null) {
            result.error("PERMISSION_REQUEST_ACTIVE", "A notification permission request is already active", null)
            return
        }
        permissionResult = result
        requestPermissions(
            arrayOf(Manifest.permission.POST_NOTIFICATIONS),
            NOTIFICATION_PERMISSION_REQUEST,
        )
    }

    @Deprecated("Deprecated in Android API 33; Flutter only requests notifications")
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray,
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == NOTIFICATION_PERMISSION_REQUEST) {
            val granted = grantResults.isNotEmpty() &&
                grantResults[0] == PackageManager.PERMISSION_GRANTED
            permissionResult?.success(granted)
            permissionResult = null
        }
    }

    companion object {
        private const val NOTIFICATION_PERMISSION_REQUEST = 9142
    }
}
