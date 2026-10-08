import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_ai_coding_academy/main.dart';
import 'package:myanmar_ai_coding_academy/lessons.dart';

void main() {
  test('Starter lesson library contains ten unique lessons', () {
    expect(pythonLessons.length, 10);
    expect(pythonLessons.map((e) => e.id).toSet().length, 10);
    expect(pythonLessons.every((e) => e.code.isNotEmpty), isTrue);
  });

  testWidgets('Home and Learn navigation renders', (tester) async {
    await tester.pumpWidget(const CodingAcademyApp());
    await tester.pumpAndSettle();
    expect(find.text('Code Lab'), findsWidgets);
    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Python သင်ခန်းစာများ'), findsOneWidget);
    expect(find.text('Introduction to Python'), findsNothing);
  });
}
