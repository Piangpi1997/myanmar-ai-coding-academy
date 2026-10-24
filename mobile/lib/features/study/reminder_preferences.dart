import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReminderPreferences {
  const ReminderPreferences({
    this.enabled = false,
    this.hour = 18,
    this.minute = 0,
    this.weekdays = const [1, 2, 3, 4, 5],
    this.studyMinutes = 15,
    this.reviewEnabled = false,
  });

  final bool enabled;
  final int hour;
  final int minute;
  final List<int> weekdays; // ISO weekday: Monday = 1, Sunday = 7.
  final int studyMinutes;
  final bool reviewEnabled;

  bool get isValid =>
      hour >= 0 &&
      hour <= 23 &&
      minute >= 0 &&
      minute <= 59 &&
      [15, 25, 45, 60].contains(studyMinutes) &&
      weekdays.every((day) => day >= 1 && day <= 7) &&
      weekdays.toSet().length == weekdays.length &&
      (!enabled || weekdays.isNotEmpty);

  ReminderPreferences copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    List<int>? weekdays,
    int? studyMinutes,
    bool? reviewEnabled,
  }) {
    final sortedWeekdays = (weekdays ?? this.weekdays).toSet().toList();
    sortedWeekdays.sort();
    return ReminderPreferences(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: List<int>.unmodifiable(sortedWeekdays),
      studyMinutes: studyMinutes ?? this.studyMinutes,
      reviewEnabled: reviewEnabled ?? this.reviewEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
    'enabled': enabled,
    'hour': hour,
    'minute': minute,
    'weekdays': weekdays,
    'study_minutes': studyMinutes,
    'review_enabled': reviewEnabled,
  };

  factory ReminderPreferences.fromJson(Map<String, dynamic> json) {
    final selectedDays = (json['weekdays'] as List<dynamic>? ??
            const [1, 2, 3, 4, 5])
        .map((day) => (day as num).toInt())
        .toSet()
        .toList();
    selectedDays.sort();
    final value = ReminderPreferences(
      enabled: json['enabled'] == true,
      hour: (json['hour'] as num?)?.toInt() ?? 18,
      minute: (json['minute'] as num?)?.toInt() ?? 0,
      weekdays: List<int>.unmodifiable(selectedDays),
      studyMinutes: (json['study_minutes'] as num?)?.toInt() ?? 15,
      reviewEnabled: json['review_enabled'] == true,
    );
    if (!value.isValid) throw const FormatException('Invalid reminder settings');
    return value;
  }
}

class ReminderPreferencesStore {
  ReminderPreferencesStore(this.prefs);
  final SharedPreferences prefs;

  static String storageKey(String? owner) => 'reminder.v1.${owner ?? 'guest'}';

  ReminderPreferences read(String? owner) {
    final raw = prefs.getString(storageKey(owner));
    if (raw == null) return const ReminderPreferences();
    try {
      return ReminderPreferences.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      // Leave unreadable stored data in place rather than silently replacing it.
      return const ReminderPreferences();
    }
  }

  Future<void> write(String? owner, ReminderPreferences value) async {
    if (!value.isValid) throw ArgumentError.value(value, 'value');
    if (!await prefs.setString(storageKey(owner), jsonEncode(value.toJson()))) {
      throw StateError('Could not save reminder preferences');
    }
  }
}

class ReminderPlatform {
  ReminderPlatform({MethodChannel? channel, bool? supported})
    : _channel = channel ?? const MethodChannel('academy/reminders'),
      _supported = supported ?? Platform.isAndroid;

  final MethodChannel _channel;
  final bool _supported;

  Future<bool> requestPermission() async {
    if (!_supported) return false;
    return await _channel.invokeMethod<bool>('requestPermission') ?? false;
  }

  Future<void> schedule(
    ReminderPreferences preferences, {
    required bool english,
  }) async {
    if (!_supported) throw UnsupportedError('Android notifications are unavailable');
    if (!preferences.isValid || !preferences.enabled) {
      throw ArgumentError.value(preferences, 'preferences');
    }
    await _channel.invokeMethod<void>('schedule', {
      ...preferences.toJson(),
      'english': english,
    });
  }

  Future<void> cancel() async {
    if (_supported) await _channel.invokeMethod<void>('cancel');
  }
}
