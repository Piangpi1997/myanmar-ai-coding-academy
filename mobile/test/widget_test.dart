import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_ai_coding_academy/main.dart';
import 'package:myanmar_ai_coding_academy/lessons.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
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
  testWidgets('Language switches instantly and persists the choice', (
    tester,
  ) async {
    await tester.pumpWidget(const CodingAcademyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Start coding today!'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getBool('english_ui'),
      isTrue,
    );
    await tester.tap(find.text('မြန်မာ'));
    await tester.pumpAndSettle();
    expect(find.text('Coding ကို ဒီနေ့ စလိုက်ပါ!'), findsOneWidget);
  });
}
