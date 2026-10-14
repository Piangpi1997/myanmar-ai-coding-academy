import 'dart:convert';
import 'package:flutter/foundation.dart';

@immutable
class ReminderPreferences {
  final bool enabled;
  final int hour;
  final int minute;
  final List<int> weekdays;
  final int durationMinutes;
  final bool reviewReminderEnabled;
  final String languageCode;
  final String accountScope;

  ReminderPreferences({
    this.enabled = false,
    this.hour = 20,
    this.minute = 0,
    Iterable<int> weekdays = const <int>[1, 2, 3, 4, 5, 6, 7],
    this.durationMinutes = 30,
    this.reviewReminderEnabled = true,
    this.languageCode = 'my',
    this.accountScope = 'guest',
  })  : assert(hour >= 0 && hour <= 23, 'hour must be between 0 and 23'),
        assert(minute >= 0 && minute <= 59, 'minute must be between 0 and 59'),
        assert(durationMinutes >= 5 && durationMinutes <= 240,
            'durationMinutes must be between 5 and 240'),
        weekdays = _normalizeWeekdays(weekdays);

  static List<int> _normalizeWeekdays(Iterable<int> rawDays) {
    final List<int> sortedDays = rawDays
        .where((int d) => d >= 1 && d <= 7)
        .toSet()
        .toList();
    sortedDays.sort();
    return List<int>.unmodifiable(sortedDays);
  }

  String get formattedTime {
    final String hh = hour.toString().padLeft(2, '0');
    final String mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  String get notificationTitle {
    if (languageCode == 'en') {
      return 'Time for Python Practice ($durationMinutes min)';
    }
    return 'Python လေ့လာရန် အချိန်ကျပါပြီ ($durationMinutes မိနစ်)';
  }

  String get notificationBody {
    if (languageCode == 'en') {
      return reviewReminderEnabled
          ? 'Continue your coding streak and review your recent lessons!'
          : 'Open Myanmar AI Coding Academy for your daily $durationMinutes-minute session.';
    }
    return reviewReminderEnabled
        ? 'နေ့စဉ် coding အလေ့အကျင့်ကို ဆက်လက်လုပ်ဆောင်ပြီး သင်ခန်းစာဟောင်းများကို ပြန်လည်လေ့လာပါ။'
        : 'ယနေ့အတွက် $durationMinutes မိနစ်စာ သင်ခန်းစာကို စတင်လိုက်ပါ။';
  }

  ReminderPreferences copyWith({
    bool? enabled,
    int? hour,
    int? minute,
    Iterable<int>? weekdays,
    int? durationMinutes,
    bool? reviewReminderEnabled,
    String? languageCode,
    String? accountScope,
  }) {
    return ReminderPreferences(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reviewReminderEnabled:
          reviewReminderEnabled ?? this.reviewReminderEnabled,
      languageCode: languageCode ?? this.languageCode,
      accountScope: accountScope ?? this.accountScope,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'enabled': enabled,
      'hour': hour,
      'minute': minute,
      'weekdays': weekdays,
      'durationMinutes': durationMinutes,
      'reviewReminderEnabled': reviewReminderEnabled,
      'languageCode': languageCode,
      'accountScope': accountScope,
    };
  }

  factory ReminderPreferences.fromJson(Map<String, dynamic> json) {
    final dynamic rawDays = json['weekdays'];
    final Iterable<int> parsedDays = rawDays is Iterable
        ? rawDays.whereType<num>().map((num e) => e.toInt())
        : const <int>[1, 2, 3, 4, 5, 6, 7];

    final int parsedHour =
        (json['hour'] is num) ? (json['hour'] as num).toInt().clamp(0, 23) : 20;
    final int parsedMinute = (json['minute'] is num)
        ? (json['minute'] as num).toInt().clamp(0, 59)
        : 0;
    final int parsedDuration = (json['durationMinutes'] is num)
        ? (json['durationMinutes'] as num).toInt().clamp(5, 240)
        : 30;

    return ReminderPreferences(
      enabled: json['enabled'] == true,
      hour: parsedHour,
      minute: parsedMinute,
      weekdays: parsedDays,
      durationMinutes: parsedDuration,
      reviewReminderEnabled: json['reviewReminderEnabled'] != false,
      languageCode: (json['languageCode'] as String?) ?? 'my',
      accountScope: (json['accountScope'] as String?) ?? 'guest',
    );
  }

  String encode() => jsonEncode(toJson());

  factory ReminderPreferences.decode(String raw, {String scope = 'guest'}) {
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ReminderPreferences.fromJson(decoded).copyWith(
          accountScope: scope,
        );
      }
    } catch (_) {}
    return ReminderPreferences(accountScope: scope);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReminderPreferences &&
        other.enabled == enabled &&
        other.hour == hour &&
        other.minute == minute &&
        listEquals(other.weekdays, weekdays) &&
        other.durationMinutes == durationMinutes &&
        other.reviewReminderEnabled == reviewReminderEnabled &&
        other.languageCode == languageCode &&
        other.accountScope == accountScope;
  }

  @override
  int get hashCode => Object.hash(
        enabled,
        hour,
        minute,
        Object.hashAll(weekdays),
        durationMinutes,
        reviewReminderEnabled,
        languageCode,
        accountScope,
      );
}
