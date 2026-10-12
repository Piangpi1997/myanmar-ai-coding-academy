import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myanmar_ai_coding_academy/main.dart';
import 'package:myanmar_ai_coding_academy/features/ai/byok_store.dart';
import 'package:myanmar_ai_coding_academy/features/ai/provider_page.dart';
import 'package:myanmar_ai_coding_academy/features/ai/tutor_page.dart';
import 'package:myanmar_ai_coding_academy/l10n/generated/app_localizations.dart';

Widget host(Widget child) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: child),
);
void main() {
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({});
  });
  test(
    'Guest credentials are isolated from accounts and legacy proxy configs survive',
    () async {
      await ByokStore.save(
        'guest',
        const ByokConfig(
          provider: 'groq',
          model: 'model',
          key: 'fake-guest-key',
        ),
      );
      await ByokStore.save(
        'A',
        const ByokConfig(
          provider: 'openai',
          model: 'other',
          key: 'fake-account-key',
        ),
      );
      expect((await ByokStore.read('guest'))!.transport, 'direct');
      expect((await ByokStore.read('A'))!.key, 'fake-account-key');
      await ByokStore.remove('guest');
      expect(await ByokStore.read('guest'), isNull);
      expect((await ByokStore.read('A'))!.key, 'fake-account-key');
      FlutterSecureStorage.setMockInitialValues({
        'byok.v1.B': jsonEncode({
          'provider': 'openrouter',
          'model': 'model',
          'key': 'fake-old-key',
        }),
      });
      expect((await ByokStore.read('B'))!.transport, 'backend');
    },
  );
  testWidgets('Guest can open Provider settings and type a tutor message', (
    tester,
  ) async {
    await tester.pumpWidget(host(TutorPage(account: null, onCode: (_) {})));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Python variable ဆိုတာဘာလဲ');
    expect(find.text('Python variable ဆိုတာဘာလဲ'), findsOneWidget);
    await tester.tap(find.text('AI provider'));
    await tester.pumpAndSettle();
    expect(find.byType(ProviderPage), findsOneWidget);
    expect(find.text('openrouter'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Load available models'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.text('Load available models'), findsOneWidget);
  });
  testWidgets('Guest saves a BYOK configuration without Supabase login', (
    tester,
  ) async {
    await tester.pumpWidget(host(const ProviderPage(account: null)));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'test/model');
    await tester.enterText(fields.at(1), 'fake-test-key');
    await tester.ensureVisible(find.byType(CheckboxListTile));
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pump();
    await tester.ensureVisible(find.text('Save'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    final saved = await ByokStore.read('guest');
    expect(saved!.model, 'test/model');
    expect(saved.transport, 'direct');
    expect(saved.key, 'fake-test-key');
    expect(find.text('fake-test-key'), findsNothing);
  });
  testWidgets(
    'Guest chat sends once and restores encrypted conversation on reopening',
    (tester) async {
      await ByokStore.save(
        'guest',
        const ByokConfig(
          provider: 'groq',
          model: 'test-model',
          key: 'fake-test-key',
        ),
      );
      var calls = 0;
      await tester.pumpWidget(
        host(
          TutorPage(
            account: null,
            onCode: (_) {},
            request: (config, payload, account) async {
              calls++;
              expect(account, isNull);
              expect(payload['messages'].last['content'], 'Explain variables');
              return {
                'content': 'Test reply from an injected test transport.',
                'executed': false,
              };
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Explain variables');
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pumpAndSettle();
      expect(calls, 1);
      expect(
        find.text('Test reply from an injected test transport.'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(host(TutorPage(account: null, onCode: (_) {})));
      await tester.pumpAndSettle();
      expect(
        find.text('Test reply from an injected test transport.'),
        findsOneWidget,
      );
    },
  );
  testWidgets(
    'Small keyboard viewport keeps the composer usable without overflow',
    (tester) async {
      await tester.pumpWidget(
        host(
          SizedBox(
            height: 250,
            child: TutorPage(account: null, onCode: (_) {}),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'A question');
      expect(tester.takeException(), isNull);
      final rect = tester.getRect(find.byType(TextField));
      expect(rect.height, greaterThan(30));
      expect(rect.bottom, lessThanOrEqualTo(250));
    },
  );
  testWidgets('Main app hides navigation while Android keyboard is open', (
    tester,
  ) async {
    await tester.pumpWidget(const CodingAcademyApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.smart_toy_outlined).last);
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    await tester.enterText(find.byType(TextField), 'မြန်မာစာ မေးခွန်း');
    expect(tester.takeException(), isNull);
  });
}
