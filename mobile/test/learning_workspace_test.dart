import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myanmar_ai_coding_academy/core/secure_store.dart';
import 'package:myanmar_ai_coding_academy/features/learning/learning_catalog.dart';
import 'package:myanmar_ai_coding_academy/features/learning/learning_hub_page.dart';
import 'package:myanmar_ai_coding_academy/features/learning/project_page.dart';
import 'package:myanmar_ai_coding_academy/features/learning/project_store.dart';
import 'package:myanmar_ai_coding_academy/features/learning/exercise_page.dart';
import 'package:myanmar_ai_coding_academy/features/learning/attempt_history_page.dart';
import 'package:myanmar_ai_coding_academy/features/learning/grade_result.dart';
import 'package:myanmar_ai_coding_academy/l10n/generated/app_localizations.dart';
import 'package:myanmar_ai_coding_academy/lessons.dart';

Widget host(Widget child, {String locale = 'en'}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: child,
);
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LearningCatalog fixture;
  setUpAll(() async {
    fixture = await LearningCatalog.load();
  });
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test(
    'Catalog is available offline, fully bilingual and references only shipped lessons',
    () async {
      final catalog = await LearningCatalog.load();
      expect(catalog.exercises.length, 6);
      expect(catalog.projects.length, 16);
      expect(catalog.paths.length, 7);
      final ids = pythonLessons.map((l) => l.id).toSet();
      for (final path in catalog.paths) {
        expect(ids.containsAll(path.lessonIds), true);
        expect(
          catalog.exercises
              .map((e) => e.id)
              .toSet()
              .containsAll(path.exerciseIds),
          true,
        );
        expect(
          catalog.projects
              .map((p) => p.id)
              .toSet()
              .containsAll(path.projectIds),
          true,
        );
      }
      for (final project in catalog.projects) {
        expect(project.steps.length, greaterThanOrEqualTo(5));
        expect(
          project.steps.map((s) => s.id).toSet().length,
          project.steps.length,
        );
        expect(
          project.objective.my.isNotEmpty && project.objective.en.isNotEmpty,
          true,
        );
      }
    },
  );
  test(
    'Project progress is isolated and unknown migrated step IDs are discarded',
    () async {
      await ProjectStore.save(
        null,
        'calculator',
        const ProjectRecord(
          completed: {'s1', 'old-step'},
          notes: 'Guest notes',
        ),
      );
      await ProjectStore.save(
        'A',
        'calculator',
        const ProjectRecord(completed: {'s2'}, notes: 'Private A'),
      );
      final guest = await ProjectStore.load(null, 'calculator', {'s1', 's2'});
      expect(guest.completed, {'s1'});
      expect(guest.notes, 'Guest notes');
      expect(
        (await ProjectStore.load('A', 'calculator', {'s1', 's2'})).notes,
        'Private A',
      );
      expect(
        (await ProjectStore.load('B', 'calculator', {'s1', 's2'})).completed,
        isEmpty,
      );
    },
  );
  test(
    'Submission IDs are valid UUID v4 receipts and invalid passing results are rejected',
    () {
      final ids = List.generate(100, (_) => submissionId());
      expect(ids.toSet().length, 100);
      expect(
        ids.every(
          (id) => RegExp(
            r'^[a-f0-9]{8}-[a-f0-9]{4}-4[a-f0-9]{3}-[89ab][a-f0-9]{3}-[a-f0-9]{12}$',
          ).hasMatch(id),
        ),
        true,
      );
      final record = {
        'id': ids.first,
        'exercise_id': 'sum-two',
        'state': 'complete',
        'feedback': 'passed',
        'passed_count': 3,
        'total_count': 3,
      };
      expect(GradeResult.fromJson(record).passed, 3);
      expect(
        () => GradeResult.fromJson({...record, 'passed_count': 0}),
        throwsFormatException,
      );
      expect(
        () => GradeResult.fromJson({...record, 'state': 'error'}),
        throwsFormatException,
      );
      expect(
        () => GradeResult.fromJson({...record, 'id': '-' * 36}),
        throwsFormatException,
      );
      expect(
        () => GradeResult.fromJson({
          ...record,
          'state': 'complete',
          'feedback': 'pending',
        }),
        throwsFormatException,
      );
    },
  );
  testWidgets('Learning workspace navigates paths, challenges and projects', (
    tester,
  ) async {
    String? lesson;
    await tester.pumpWidget(
      host(
        LearningHubPage(
          account: null,
          completed: {'py-01'},
          loadCatalog: () async => fixture,
          onLesson: (id) => lesson = id,
          onCode: (_) async {},
          onTutor: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Complete Beginner'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose this path'));
    await tester.pumpAndSettle();
    expect(await secureStorage.read(key: 'learning-path.v1.guest'), 'beginner');
    await tester.tap(find.text('Introduction to Python'));
    expect(lesson, 'py-01');
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coding challenges'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add two integers'));
    await tester.pumpAndSettle();
    expect(find.byType(ExercisePage), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('Guided projects'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Calculator'));
    await tester.pumpAndSettle();
    expect(find.byType(ProjectPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'Project checkpoints and notes survive reopening without fabricated verification',
    (tester) async {
      final project = fixture.projects.first;
      await tester.pumpWidget(
        host(
          ProjectPage(project: project, account: null, onCode: (_) async {}),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('project.step.s1')),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.byKey(const ValueKey('project.step.s1')));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(TextField),
        350,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
        find.byType(TextField),
        'Tested zero division on my computer.',
      );
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      final saved = await ProjectStore.load(
        null,
        project.id,
        project.steps.map((s) => s.id).toSet(),
      );
      expect(saved.completed, {'s1'});
      expect(saved.notes, 'Tested zero division on my computer.');
      await tester.pumpWidget(
        host(
          ProjectPage(project: project, account: null, onCode: (_) async {}),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('1 / 5'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('1 / 5'), findsOneWidget);
    },
  );
  testWidgets(
    'Guest exercise editing is persistent and run does not simulate output',
    (tester) async {
      final exercise = fixture.exercises.first;
      await tester.pumpWidget(
        host(ExercisePage(exercise: exercise, account: null, onTutor: (_) {})),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(TextField),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField), 'print(42)');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Run example'),
        250,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(find.text('Run example'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.textContaining(
          'Sign in with a configured backend to execute Python',
        ),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.textContaining(
          'Sign in with a configured backend to execute Python',
        ),
        findsOneWidget,
      );
      expect(find.text('42'), findsNothing);
      final saved = jsonDecode(
        (await secureStorage.read(key: 'exercise.v1.guest.sum-two'))!,
      );
      expect(saved['code'], 'print(42)');
      expect(saved['grade'], isNull);
    },
  );
  testWidgets('Broken project data is retained when the reader closes', (
    tester,
  ) async {
    final project = fixture.projects.first;
    await secureStorage.write(
      key: ProjectStore.key(null, project.id),
      value: 'broken-original-record',
    );
    await tester.pumpWidget(
      host(ProjectPage(project: project, account: null, onCode: (_) async {})),
    );
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    expect(
      await secureStorage.read(key: ProjectStore.key(null, project.id)),
      'broken-original-record',
    );
  });
  testWidgets(
    'A stale account route never reads or overwrites another account project',
    (tester) async {
      final project = fixture.projects.first;
      await ProjectStore.save(
        'A',
        project.id,
        const ProjectRecord(notes: 'Private old account'),
      );
      await tester.pumpWidget(
        host(ProjectPage(project: project, account: 'A', onCode: (_) async {})),
      );
      await tester.pumpAndSettle();
      expect(find.text('Private old account'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
      expect(
        (await ProjectStore.load('A', project.id, {'s1'})).notes,
        'Private old account',
      );
    },
  );
  testWidgets(
    'Assessment history hides stale-account records before any API request',
    (tester) async {
      await tester.pumpWidget(host(const AttemptHistoryPage(account: 'A')));
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.textContaining('session'), findsOneWidget);
    },
  );
}
