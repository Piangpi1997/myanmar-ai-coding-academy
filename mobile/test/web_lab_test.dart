import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_ai_coding_academy/core/secure_store.dart';
import 'package:myanmar_ai_coding_academy/features/code/web_project.dart';
import 'package:myanmar_ai_coding_academy/features/code/web_lab_page.dart';
import 'package:myanmar_ai_coding_academy/l10n/generated/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
  });
  test('Project serialization rejects corrupt or excessive drafts', () {
    expect(
      WebProject.decode(WebProject.starter.encode()).html,
      WebProject.starter.html,
    );
    for (final raw in [
      'null',
      '{}',
      '{"version":2}',
      jsonEncode({
        'version': 1,
        'html': 'x' * 16001,
        'css': '',
        'javascript': '',
      }),
    ]) {
      expect(() => WebProject.decode(raw), throwsFormatException);
    }
    expect(
      () => WebProject(
        html: 'x' * 16001,
        css: '',
        javascript: '',
      ).previewDocument(),
      throwsFormatException,
    );
  });
  test('Preview keeps learner markup inside an opaque restricted iframe', () {
    const project = WebProject(
      html:
          '"><iframe></iframe><script>parent.document.body.innerHTML="bad";</script>',
      css: 'p:before{content:"</STYLE>"}',
      javascript: 'if (1 < 2) console.log("</ScRiPt>");',
    );
    final rendered = project.previewDocument();
    expect(RegExp('<iframe ').allMatches(rendered).length, 1);
    expect(rendered, contains('sandbox="allow-scripts"'));
    expect(rendered, isNot(contains('allow-same-origin')));
    expect(rendered, contains("connect-src 'none'"));
    expect(rendered, contains('referrerpolicy="no-referrer"'));
    expect(rendered, contains('if (1 &lt; 2)'));
    expect(rendered, contains('&lt;\\/ScRiPt&gt;'));
    expect(rendered, isNot(contains('<script>parent')));
  });
  testWidgets(
    'Guest edits all web tabs and restores encrypted local draft without an account',
    (tester) async {
      Widget app() => MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const WebLabPage(account: null),
      );
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('Web Code Lab'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '<h1>My saved page</h1>');
      await tester.tap(find.text('CSS'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'h1 { color: purple; }');
      await tester.tap(find.text('JavaScript'));
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'console.log("saved");');
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      final raw = await secureStorage.read(key: 'web.v1.guest');
      final saved = WebProject.decode(raw!);
      expect(saved.html, '<h1>My saved page</h1>');
      expect(saved.css, 'h1 { color: purple; }');
      expect(saved.javascript, 'console.log("saved");');
      expect(await secureStorage.read(key: 'web.v1.other-account'), null);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();
      expect(find.text('<h1>My saved page</h1>'), findsOneWidget);
    },
  );
  testWidgets('Unreadable drafts are preserved when closing the page', (
    tester,
  ) async {
    await secureStorage.write(key: 'web.v1.guest', value: 'broken');
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const WebLabPage(account: null),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNothing);
    expect(find.text('Retry'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(await secureStorage.read(key: 'web.v1.guest'), 'broken');
  });
}
