import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:myanmar_ai_coding_academy/lessons.dart';
import 'package:myanmar_ai_coding_academy/lesson_guides.dart';
import 'package:myanmar_ai_coding_academy/features/learning/lesson_quiz.dart';
import 'package:myanmar_ai_coding_academy/l10n/generated/app_localizations.dart';

Widget host() => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(
    body: LessonQuiz(
      lessonId: 'py-02',
      guide: lessonGuides['py-02']!,
      english: true,
    ),
  ),
);
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Every shipped lesson has bilingual original guides and valid quiz options',
    () {
      expect(
        lessonGuides.keys.toSet(),
        academyLessons.map((l) => l.id).toSet(),
      );
      for (final guide in lessonGuides.values) {
        for (final text in [guide.my, guide.en]) {
          expect(text['body']!.length, greaterThan(650));
          expect(
            text.keys,
            containsAll([
              'objectives',
              'lines',
              'mistake',
              'hint',
              'challenge',
              'question',
              'explanation',
            ]),
          );
        }
        expect(guide.correct, inInclusiveRange(0, guide.enOptions.length - 1));
        expect(guide.myOptions.length, guide.enOptions.length);
        final reference = Uri.parse(guide.reference);
        expect(reference.scheme, 'https');
        expect(reference.userInfo, isEmpty);
        expect(
          const {
            'docs.python.org',
            'git-scm.com',
            'developer.mozilla.org',
            'www.kali.org',
            'www.sqlite.org',
            'www.gnu.org',
            'man7.org',
            'nmap.org',
            'curl.se',
            'www.wireshark.org',
            'cheatsheetseries.owasp.org',
          },
          contains(reference.host),
          reason: guide.reference,
        );
      }
    },
  );
  testWidgets(
    'Quiz gives correct and incorrect feedback and persists guest attempts only',
    (tester) async {
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('Check answer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Try again'), findsOneWidget);
      await tester.tap(find.text('5'));
      await tester.pump();
      await tester.tap(find.text('Check answer'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Correct'), findsOneWidget);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getInt('quiz.v1.guest.py-02.attempts'), 2);
      expect(prefs.getInt('quiz.v1.guest.py-02.answer'), 2);
      expect(prefs.containsKey('quiz.v1.A.py-02.answer'), false);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      expect(find.text('Local attempts: 2'), findsOneWidget);
      expect(find.textContaining('Correct'), findsOneWidget);
    },
  );
}
