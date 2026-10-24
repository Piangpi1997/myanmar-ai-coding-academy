import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_ai_coding_academy/main.dart';
import 'package:myanmar_ai_coding_academy/lessons.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('Course preserves starter IDs and ships 40 unique lessons', () {
    expect(pythonLessons.length, 40);
    expect(pythonLessons.map((e) => e.id).toSet().length, 40);
    expect(pythonLessons.every((e) => e.code.isNotEmpty), isTrue);
    expect(
      pythonLessons.map((lesson) => lesson.id),
      containsAll(['py-37', 'py-38', 'py-39', 'py-40']),
    );
  });

  testWidgets('Home and Learn navigation renders', (tester) async {
    await tester.pumpWidget(const CodingAcademyApp());
    await tester.pumpAndSettle();
    expect(find.text('Code Lab'), findsWidgets);
    await tester.tap(find.byIcon(Icons.school_outlined));
    await tester.pumpAndSettle();
    expect(find.text('သင်ခန်းစာ စာကြည့်တိုက်'), findsOneWidget);
    expect(find.text('Introduction to Python'), findsNothing);
  });
  testWidgets('Language switches instantly and persists the choice', (
    tester,
  ) async {
    await tester.pumpWidget(const CodingAcademyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(find.text('Build a little, learn a lot.'), findsOneWidget);
    expect(
      (await SharedPreferences.getInstance()).getBool('english_ui'),
      isTrue,
    );
    await tester.tap(find.text('မြန်မာ'));
    await tester.pumpAndSettle();
    expect(find.text('တစ်နေ့ နည်းနည်းချင်း လေ့လာပါ'), findsOneWidget);
  });
}
