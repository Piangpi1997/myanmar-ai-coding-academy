import 'package:flutter_test/flutter_test.dart';
import '../lib/features/study/reminder_preferences.dart';
import '../lib/features/study/study_store.dart';
import '../lib/features/study/study_tracker.dart';

void main() {
  group('ReminderPreferences Tests', () {
    test('normalizes, deduplicates, and sorts weekdays without cascade errors', () {
      final ReminderPreferences prefs = ReminderPreferences(
        enabled: true,
        hour: 19,
        minute: 30,
        weekdays: <int>[5, 1, 3, 5, 7, 1, 99, 0],
        durationMinutes: 45,
        languageCode: 'my',
        accountScope: 'user_123',
      );

      expect(prefs.weekdays, equals(<int>[1, 3, 5, 7]));
      expect(prefs.formattedTime, equals('19:30'));
      expect(() => prefs.weekdays.add(2), throwsUnsupportedError);
    });

    test('serializes and deserializes accurately with accountScope isolation', () {
      final ReminderPreferences original = ReminderPreferences(
        enabled: true,
        hour: 8,
        minute: 5,
        weekdays: <int>[6, 2, 4],
        durationMinutes: 25,
        reviewReminderEnabled: false,
        languageCode: 'en',
        accountScope: 'user_abc',
      );

      final String encoded = original.encode();
      final ReminderPreferences restored =
          ReminderPreferences.decode(encoded, scope: 'user_abc');

      expect(restored, equals(original));
      expect(restored.weekdays, equals(<int>[2, 4, 6]));
    });
  });

  group('StudyStore Isolation & Idempotency Tests', () {
    test('deduplicates checkpoints and isolates guest vs authenticated user', () async {
      final InMemoryKeyValueStorage storage = InMemoryKeyValueStorage();
      int cloudSyncCalls = 0;

      final StudyStore store = StudyStore(
        storage: storage,
        cloudSyncCallback: (StudyCheckpoint chk) async {
          cloudSyncCalls += 1;
          return true;
        },
      );

      final DateTime now = DateTime.now().toUtc();
      final StudyCheckpoint guestChk = StudyCheckpoint(
        checkpointId: 'chk_guest_1',
        accountScope: 'guest',
        lessonId: 'py-001',
        activityType: 'lesson_reading',
        foregroundSeconds: 120,
        startedAt: now.subtract(const Duration(seconds: 120)),
        endedAt: now,
        completedReading: true,
      );

      await store.saveCheckpoint(guestChk);
      await store.saveCheckpoint(guestChk);

      expect(await store.getTotalStudySeconds('guest'), equals(120));
      expect(cloudSyncCalls, equals(0));
      expect(await store.getTotalStudySeconds('user_999'), equals(0));
    });
  });
}
