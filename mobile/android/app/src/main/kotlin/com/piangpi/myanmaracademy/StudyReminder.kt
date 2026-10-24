package com.piangpi.myanmaracademy

import android.app.AlarmManager
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import org.json.JSONObject
import java.util.Calendar

internal object StudyReminderScheduler {
    private const val STORE = "academy_study_reminders"
    private const val CONFIG = "active_config"
    private const val CHANNEL = "study_reminders"
    private const val FIRST_ID = 4100

    fun schedule(context: Context, config: JSONObject) {
        cancelAlarms(context)
        context.getSharedPreferences(STORE, Context.MODE_PRIVATE)
            .edit().putString(CONFIG, config.toString()).apply()
        if (!config.optBoolean("enabled", false)) return
        val days = config.optJSONArray("weekdays") ?: return
        for (index in 0 until days.length()) {
            val day = days.optInt(index, -1)
            if (day in 1..7) {
                scheduleNext(context, day, 1)
                if (config.optBoolean("review_enabled", false)) scheduleNext(context, day, 2)
            }
        }
    }

    fun cancel(context: Context) {
        cancelAlarms(context)
        context.getSharedPreferences(STORE, Context.MODE_PRIVATE)
            .edit().remove(CONFIG).apply()
    }

    fun reschedule(context: Context) {
        val raw = context.getSharedPreferences(STORE, Context.MODE_PRIVATE).getString(CONFIG, null)
            ?: return
        val config = try { JSONObject(raw) } catch (_: Exception) { return }
        schedule(context, config)
    }

    private fun cancelAlarms(context: Context) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        for (day in 1..7) for (kind in 1..2) {
            val pending = pendingIntent(context, day, kind)
            alarmManager.cancel(pending)
            pending.cancel()
        }
    }

    private fun pendingIntent(context: Context, day: Int, kind: Int): PendingIntent {
        val intent = Intent(context, StudyReminderReceiver::class.java)
            .putExtra("iso_day", day)
            .putExtra("kind", kind)
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        return PendingIntent.getBroadcast(context, FIRST_ID + day * 10 + kind, intent, flags)
    }

    private fun scheduleNext(context: Context, isoDay: Int, kind: Int) {
        val config = activeConfig(context) ?: return
        if (!config.optBoolean("enabled", false)) return
        if (kind == 2 && !config.optBoolean("review_enabled", false)) return
        val days = config.optJSONArray("weekdays") ?: return
        if ((0 until days.length()).none { days.optInt(it) == isoDay }) return

        val hour = config.optInt("hour", -1)
        val minute = config.optInt("minute", -1)
        if (hour !in 0..23 || minute !in 0..59) return
        val now = Calendar.getInstance()
        val target = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, hour)
            set(Calendar.MINUTE, minute)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val androidDay = if (isoDay == 7) Calendar.SUNDAY else isoDay + 1
        val offset = (androidDay - now.get(Calendar.DAY_OF_WEEK) + 7) % 7
        target.add(Calendar.DAY_OF_YEAR, offset)
        if (!target.after(now)) {
            target.add(Calendar.DAY_OF_YEAR, 7)
        }
        if (kind == 2) target.add(Calendar.MINUTE, 45)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        alarmManager.setAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            target.timeInMillis,
            pendingIntent(context, isoDay, kind),
        )
    }

    fun deliver(context: Context, isoDay: Int, kind: Int) {
        val config = activeConfig(context) ?: return
        if (!config.optBoolean("enabled", false)) return
        if (kind == 2 && !config.optBoolean("review_enabled", false)) return
        val days = config.optJSONArray("weekdays") ?: return
        if ((0 until days.length()).none { days.optInt(it) == isoDay }) return
        if (Build.VERSION.SDK_INT >= 33 &&
            context.checkSelfPermission(android.Manifest.permission.POST_NOTIFICATIONS) !=
            PackageManager.PERMISSION_GRANTED
        ) return

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            manager.createNotificationChannel(
                NotificationChannel(CHANNEL, "Study reminders", NotificationManager.IMPORTANCE_DEFAULT),
            )
        }
        val english = config.optBoolean("english", false)
        val minutes = config.optInt("study_minutes", 15)
        val title = "Myanmar AI Coding Academy"
        val message = if (kind == 2) {
            if (english) "Take a short moment to review what you learned today."
            else "ဒီနေ့ လေ့လာခဲ့တာကို အချိန်ခဏယူပြီး ပြန်လည်လေ့ကျင့်ကြရအောင်။"
        } else {
            if (english) "Spend $minutes minutes learning a coding concept today."
            else "ဒီနေ့ Coding သင်ခန်းစာကို $minutes မိနစ် လေ့လာကြရအောင်။"
        }
        val openIntent = Intent(context, MainActivity::class.java)
        val contentIntent = PendingIntent.getActivity(
            context,
            FIRST_ID + isoDay * 10 + kind + 100,
            openIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val builder = notificationBuilder(context)
        val notification = builder
            .setSmallIcon(android.R.drawable.ic_dialog_info)
            .setContentTitle(title)
            .setContentText(message)
            .setStyle(Notification.BigTextStyle().bigText(message))
            .setAutoCancel(true)
            .setContentIntent(contentIntent)
            .build()
        manager.notify(FIRST_ID + isoDay * 10 + kind, notification)
        scheduleNext(context, isoDay, kind)
    }

    private fun activeConfig(context: Context): JSONObject? {
        val raw = context.getSharedPreferences(STORE, Context.MODE_PRIVATE).getString(CONFIG, null)
            ?: return null
        return try { JSONObject(raw) } catch (_: Exception) { null }
    }

    @Suppress("DEPRECATION")
    private fun notificationBuilder(context: Context): Notification.Builder =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(context, CHANNEL)
        } else {
            Notification.Builder(context)
        }
}

class StudyReminderReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val day = intent.getIntExtra("iso_day", -1)
        val kind = intent.getIntExtra("kind", -1)
        if (day in 1..7 && kind in 1..2) StudyReminderScheduler.deliver(context, day, kind)
    }
}

class ReminderRescheduleReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_MY_PACKAGE_REPLACED -> StudyReminderScheduler.reschedule(context)
        }
    }
}
