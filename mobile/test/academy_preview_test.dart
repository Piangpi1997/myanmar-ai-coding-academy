import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myanmar_ai_coding_academy/main.dart';
import 'package:myanmar_ai_coding_academy/core/academy_theme.dart';
import 'package:myanmar_ai_coding_academy/features/learning/practice_test_page.dart';
import 'package:myanmar_ai_coding_academy/features/code/web_lab_page.dart';
import 'package:myanmar_ai_coding_academy/l10n/generated/app_localizations.dart';

void main() {
  testWidgets(
    'clean mobile screens render in both languages and at narrow width',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(390, 844);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      FlutterSecureStorage.setMockInitialValues({});
      await tester.runAsync(() async {
        final loader = FontLoader('NotoSansMyanmar')
          ..addFont(rootBundle.load('assets/fonts/NotoSansMyanmar.ttf'));
        await loader.load();
      });
      const boundaryKey = ValueKey('preview-root');
      Future<void> capture(String name) async {
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: name);
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(boundaryKey),
        );
        await tester.runAsync(() async {
          final image = await boundary.toImage(pixelRatio: 1.5);
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          final folder = Directory('build/preview')
            ..createSync(recursive: true);
          File(
            '${folder.path}/$name.png',
          ).writeAsBytesSync(bytes!.buffer.asUint8List());
          image.dispose();
        });
      }

      await tester.pumpWidget(
        const RepaintBoundary(key: boundaryKey, child: CodingAcademyApp()),
      );
      await capture('home-my');
      await tester.tap(find.text('EN'));
      await capture('home-en');
      await tester.tap(find.byIcon(Icons.school_outlined));
      await capture('library-en');
      await tester.tap(find.byIcon(Icons.code).last);
      await capture('code-en');
      await tester.tap(find.byIcon(Icons.person_outline).last);
      await capture('profile-en');
      await tester.tap(find.byIcon(Icons.smart_toy_outlined).last);
      await capture('tutor-en');
      tester.view.physicalSize = const Size(320, 740);
      await tester.tap(find.byIcon(Icons.home_outlined));
      await capture('home-narrow-en');
      await tester.tap(find.text('မြန်မာ'));
      await capture('home-narrow-my');
      tester.view.physicalSize = const Size(390, 844);
      Widget standalone(Widget page) => RepaintBoundary(
        key: boundaryKey,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: academyTheme(Brightness.light),
          home: page,
        ),
      );
      await tester.pumpWidget(
        standalone(const PracticeTestPage(account: null, english: true)),
      );
      await capture('quiz-light-en');
      await tester.pumpWidget(standalone(const WebLabPage(account: null)));
      await capture('html-viewer-light-en');
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    },
  );
}
