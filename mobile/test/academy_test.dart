import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myanmar_ai_coding_academy/lessons.dart';
import 'package:myanmar_ai_coding_academy/lesson_guides.dart';
import 'package:myanmar_ai_coding_academy/features/learning/practice_test_page.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('120 lessons have bilingual guides and a valid quiz', () {
    expect(academyLessons, hasLength(120));
    expect(academyLessons.map((q) => q.id).toSet(), hasLength(120));
    expect(pythonLessons, hasLength(40));
    for (final q in academyLessons) {
      final guide = lessonGuides[q.id]!;
      expect(guide.my['body'], isNotEmpty);
      expect(guide.en['body'], isNotEmpty);
      expect(guide.correct, lessThan(guide.enOptions.length));
      expect(guide.myOptions.length, guide.enOptions.length);
    }
    expect(academyLessons.where((q) => q.track == 'linux'), hasLength(20));
    expect(
      academyLessons
          .where((q) => q.track == 'web')
          .every((q) => q.language == 'html'),
      isTrue,
    );
  });
  test(
    'practice selects unique questions and scores against authored answers',
    () {
      final run = PracticeRun(academyLessons, count: 20, random: Random(7));
      expect(run.questions.map((q) => q.id).toSet(), hasLength(20));
      expect(run.complete, isFalse);
      for (final q in run.questions) {
        run.answer(q.id, lessonGuides[q.id]!.correct);
      }
      expect(run.complete, isTrue);
      expect(run.score, 20);
      expect(() => run.answer('unknown', 0), throwsArgumentError);
      expect(
        () => run.answer(run.questions.first.id, 999),
        throwsArgumentError,
      );
    },
  );
  test(
    'practice history preserves corrupt data and separates account scopes',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final store = PracticeHistory(prefs);
      final run = PracticeRun(academyLessons, count: 5, random: Random(1));
      await expectLater(store.save(null, run, 'all'), throwsStateError);
      for (final q in run.questions) {
        run.answer(q.id, lessonGuides[q.id]!.correct);
      }
      await store.save(null, run, 'all');
      expect(store.read(null).single['score'], 5);
      expect(store.read('other'), isEmpty);
      await prefs.setString(PracticeHistory.key('broken'), 'not-json');
      await expectLater(
        store.save('broken', run, 'all'),
        throwsFormatException,
      );
      expect(prefs.getString(PracticeHistory.key('broken')), 'not-json');
    },
  );
  testWidgets('preview hides answers and a complete quiz persists a result', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PracticeTestPage(account: null, english: true)),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test preview'));
    await tester.pumpAndSettle();
    expect(find.text('Question preview'), findsOneWidget);
    expect(find.textContaining('Correct answer:'), findsNothing);
    await tester.scrollUntilVisible(find.text('Start these questions'), 300);
    await tester.tap(find.text('Start these questions'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await tester.ensureVisible(find.byKey(const ValueKey('answer.0')));
      await tester.tap(find.byKey(const ValueKey('answer.0')));
      await tester.pumpAndSettle();
      if (i < 9) {
        await tester.ensureVisible(find.text('Next'));
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }
    }
    await tester.ensureVisible(find.text('Submit test'));
    await tester.tap(find.text('Submit test'));
    await tester.pumpAndSettle();
    expect(find.text('Practice result'), findsOneWidget);
    final store = PracticeHistory(await SharedPreferences.getInstance());
    expect(store.read(null).single['total'], 10);
  });
}
