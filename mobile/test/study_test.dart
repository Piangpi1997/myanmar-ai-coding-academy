import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_ai_coding_academy/features/study/reminder_preferences.dart';
import 'package:myanmar_ai_coding_academy/features/study/reminders_page.dart';
import 'package:myanmar_ai_coding_academy/features/study/study_page.dart';
import 'package:myanmar_ai_coding_academy/features/study/study_store.dart';
import 'package:myanmar_ai_coding_academy/features/study/study_tracker.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StudyTracker', () {
    test('counts only explicit foreground intervals and saves unique checkpoints', () {
      var time = DateTime.utc(2026, 10, 15, 10);
      var nextId = 0;
      final tracker = StudyTracker(
        now: () => time,
        idFactory: () => 'session-${++nextId}',
      );
      tracker.start(activity: 'coding');
      time = time.add(const Duration(seconds: 61));
      expect(tracker.elapsedSeconds, 61);
      final first = tracker.checkpoint()!;
      expect(first.durationSeconds, 61);
      expect(first.activity, 'coding');
      expect(first.startedAt, DateTime.utc(2026, 10, 15, 10));
      expect(first.clientId, 'session-1');
      expect(tracker.checkpoint(), isNull);

      time = time.add(const Duration(seconds: 4));
      final finalSegment = tracker.stop()!;
      expect(finalSegment.durationSeconds, 4);
      expect(finalSegment.clientId, 'session-2');
      expect(tracker.isRunning, isFalse);
      time = time.add(const Duration(hours: 2));
      expect(tracker.elapsedSeconds, 0);
      expect(tracker.stop(), isNull);
    });

    test('pausing on a lifecycle event prevents background time being counted', () {
      var time = DateTime.utc(2026, 10, 15, 10);
      final tracker = StudyTracker(now: () => time, idFactory: () => 'one');
      tracker.start();
      time = time.add(const Duration(seconds: 20));
      expect(tracker.stop()!.durationSeconds, 20);
      time = time.add(const Duration(hours: 3));
      expect(tracker.elapsedSeconds, 0);
      tracker.start();
      time = time.add(const Duration(seconds: 7));
      expect(tracker.stop()!.durationSeconds, 7);
    });
  });

  group('StudyStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    StudySession session(String id, {bool synced = false}) => StudySession(
      clientId: id,
      startedAt: DateTime.utc(2026, 10, 15, 10),
      durationSeconds: 60,
      activity: 'lesson',
      lessonId: 'py-01',
      synced: synced,
    );

    test('guest and account histories use separate storage keys', () async {
      final store = StudyStore(await SharedPreferences.getInstance());
      await store.append(null, session('guest-id'));
      await store.append('user-a', session('account-id'));
      expect(store.read(null).map((item) => item.clientId), ['guest-id']);
      expect(store.read('user-a').map((item) => item.clientId), ['account-id']);
      expect(store.read('user-b'), isEmpty);
    });

    test('retries failed saves without discarding local checkpoints', () async {
      var attempts = 0;
      final store = StudyStore(
        await SharedPreferences.getInstance(),
        loadRemote: (_) async => [],
        saveRemote: (_, __) async {
          attempts++;
          if (attempts == 1) throw StateError('offline');
        },
      );
      await store.append('user-a', session('pending'));
      final first = await store.sync('user-a');
      expect(first.hadError, isTrue);
      expect(first.sessions.single.synced, isFalse);
      final second = await store.sync('user-a');
      expect(second.hadError, isFalse);
      expect(second.sessions.single.synced, isTrue);
      expect(attempts, 2);
    });

    test('merges cloud history and local pending history by client ID', () async {
      final store = StudyStore(
        await SharedPreferences.getInstance(),
        loadRemote: (_) async => [
          {
            'client_id': 'cloud-id',
            'started_at': '2026-10-14T10:00:00Z',
            'duration_seconds': 120,
            'activity': 'review',
            'lesson_id': null,
          },
        ],
        saveRemote: (_, __) async {},
      );
      await store.append('user-a', session('local-id'));
      final result = await store.sync('user-a');
      expect(result.hadError, isFalse);
      expect(result.sessions.map((item) => item.clientId).toSet(), {'cloud-id', 'local-id'});
      expect(result.sessions.singleWhere((item) => item.clientId == 'cloud-id').synced, isTrue);
      expect(result.sessions.singleWhere((item) => item.clientId == 'local-id').synced, isTrue);
    });

    test('does not overwrite unreadable stored history when reading', () async {
      SharedPreferences.setMockInitialValues({'study.v1.guest': '{broken'});
      final prefs = await SharedPreferences.getInstance();
      final store = StudyStore(prefs);
      expect(() => store.read(null), throwsFormatException);
      await expectLater(store.append(null, session('new')), throwsFormatException);
      expect(prefs.getString('study.v1.guest'), '{broken');
    });

    test('keeps checkpoints saved while a cloud upload is in flight', () async {
      final uploadStarted = Completer<void>();
      final allowUpload = Completer<void>();
      final store = StudyStore(
        await SharedPreferences.getInstance(),
        loadRemote: (_) async => [],
        saveRemote: (_, __) async {
          uploadStarted.complete();
          await allowUpload.future;
        },
      );
      await store.append('user-a', session('uploading'));
      final syncing = store.sync('user-a');
      await uploadStarted.future;
      await store.append('user-a', session('new-checkpoint'));
      await store.append(null, session('guest-checkpoint'));
      allowUpload.complete();
      final result = await syncing;
      expect(result.hadError, isFalse);
      expect(result.sessions.map((item) => item.clientId).toSet(), {
        'uploading',
        'new-checkpoint',
      });
      expect(result.sessions.singleWhere((item) => item.clientId == 'uploading').synced, isTrue);
      expect(result.sessions.singleWhere((item) => item.clientId == 'new-checkpoint').synced, isFalse);
      expect(store.read(null).single.clientId, 'guest-checkpoint');
    });

    test('reads existing device records without renaming storage keys', () async {
      final original = jsonEncode([session('existing').toLocalJson()]);
      SharedPreferences.setMockInitialValues({'study.v1.user-a': original});
      final prefs = await SharedPreferences.getInstance();
      final store = StudyStore(prefs);
      expect(store.read('user-a').single.clientId, 'existing');
      await store.append('user-a', session('existing'));
      expect(store.read('user-a'), hasLength(1));
      expect(prefs.getKeys(), {'study.v1.user-a'});
    });
  });

  group('Reminders', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('copyWith sorts a copy and keeps the native reminder payload', () {
      final selectedDays = [5, 1, 3, 5];
      const original = ReminderPreferences();
      final changed = original.copyWith(
        weekdays: selectedDays,
        studyMinutes: 45,
        reviewEnabled: true,
      );
      expect(changed.weekdays, [1, 3, 5]);
      expect(changed.isValid, isTrue);
      expect(selectedDays, [5, 1, 3, 5]);
      expect(original.weekdays, [1, 2, 3, 4, 5]);
      expect(() => changed.weekdays.add(7), throwsUnsupportedError);
      expect(changed.toJson()['study_minutes'], 45);
      expect(changed.toJson()['review_enabled'], isTrue);
      expect(ReminderPreferences.fromJson(changed.toJson()).toJson(), changed.toJson());
    });

    test('validates choices and round-trips preferences per owner', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = ReminderPreferencesStore(prefs);
      const enabled = ReminderPreferences(
        enabled: true,
        hour: 7,
        minute: 45,
        weekdays: [1, 3, 5],
        studyMinutes: 25,
        reviewEnabled: true,
      );
      expect(enabled.isValid, isTrue);
      await store.write('user-a', enabled);
      expect(store.read('user-a').toJson(), enabled.toJson());
      expect(store.read(null).enabled, isFalse);
      expect(
        const ReminderPreferences(enabled: true, weekdays: []).isValid,
        isFalse,
      );
      expect(
        const ReminderPreferences(hour: 24).isValid,
        isFalse,
      );
    });

    test('calls native schedule and cancellation through the method channel', () async {
      const channel = MethodChannel('test/academy-reminders');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'requestPermission') return true;
            return null;
          });
      final platform = ReminderPlatform(channel: channel, supported: true);
      expect(await platform.requestPermission(), isTrue);
      await platform.schedule(
        const ReminderPreferences(
          enabled: true,
          hour: 8,
          minute: 30,
          weekdays: [1, 5],
          studyMinutes: 45,
          reviewEnabled: true,
        ),
        english: false,
      );
      await platform.cancel();
      expect(calls.map((call) => call.method), ['requestPermission', 'schedule', 'cancel']);
      expect(calls[1].arguments['weekdays'], [1, 5]);
      expect(calls[1].arguments['english'], isFalse);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    test('does not claim native reminders on unsupported platforms', () async {
      final platform = ReminderPlatform(supported: false);
      expect(await platform.requestPermission(), isFalse);
      await platform.cancel();
      expect(
        () => platform.schedule(
          const ReminderPreferences(enabled: true),
          english: false,
        ),
        throwsUnsupportedError,
      );
    });
  });

  group('Study screen integration', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    testWidgets('study timer opens and pauses when the app leaves the foreground', (tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: StudyPage(account: null, english: true),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Study timer'), findsOneWidget);
      await tester.tap(find.text('Start studying'));
      await tester.pump();
      expect(find.text('Pause and save'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(find.text('Start studying'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(find.text('Start studying'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
    });

    testWidgets('reminder screen saves through the native channel and restores settings', (tester) async {
      const channel = MethodChannel('test/study-screen-reminders');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            return call.method == 'requestPermission' ? true : null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });
      final platform = ReminderPlatform(channel: channel, supported: true);
      await tester.pumpWidget(MaterialApp(
        home: RemindersPage(account: 'user-a', english: true, platform: platform),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Enable daily study reminders'));
      await tester.pump();
      await tester.scrollUntilVisible(find.text('Save and schedule'), 250);
      await tester.tap(find.text('Save and schedule'));
      await tester.pumpAndSettle();
      final prefs = await SharedPreferences.getInstance();
      final saved = ReminderPreferencesStore(prefs).read('user-a');
      expect(saved.enabled, isTrue);
      expect(ReminderPreferencesStore(prefs).read(null).enabled, isFalse);
      expect(calls.map((call) => call.method), ['requestPermission', 'schedule']);
      expect(calls.last.arguments['study_minutes'], 15);
      expect(calls.last.arguments['english'], isTrue);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(MaterialApp(
        home: RemindersPage(account: 'user-a', english: true, platform: platform),
      ));
      await tester.pumpAndSettle();
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile).first).value, isTrue);
      expect(calls.where((call) => call.method == 'schedule'), hasLength(2));
      await tester.pumpWidget(const SizedBox.shrink());
    });
  });
}
