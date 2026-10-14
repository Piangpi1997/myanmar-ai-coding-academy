import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_ai_coding_academy/features/learning/course_browser.dart';

void main() {
  testWidgets('Learner can search, open and hide completed lessons', (
    tester,
  ) async {
    String? opened;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CourseBrowser(
            english: true,
            completed: const {'py-27'},
            actions: const SizedBox(),
            onLesson: (lesson) => opened = lesson.id,
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), 'SQLite');
    await tester.pumpAndSettle();
    expect(find.text('1 lessons shown'), findsOneWidget);
    await tester.ensureVisible(find.text('SQLite and parameter binding'));
    await tester.tap(find.text('SQLite and parameter binding'));
    expect(opened, 'py-27');
    await tester.ensureVisible(find.text('Not completed'));
    await tester.tap(find.text('Not completed'));
    await tester.pumpAndSettle();
    expect(find.text('0 lessons shown'), findsOneWidget);
    expect(find.text('No lessons match these filters.'), findsOneWidget);
  });
}
