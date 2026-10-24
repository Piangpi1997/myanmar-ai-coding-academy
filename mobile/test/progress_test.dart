import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myanmar_ai_coding_academy/core/progress_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'Guest history stays separate and offline account progress uploads on retry',
    () async {
      SharedPreferences.setMockInitialValues({
        'completed_lessons': ['py-01'],
        'completed_A': ['py-02'],
      });
      final prefs = await SharedPreferences.getInstance();
      var offline = true;
      final uploaded = <String>[];
      final controller = ProgressController(
        prefs: prefs,
        loadRemote: (_) async {
          if (offline) throw Exception('offline');
          return {'py-03'};
        },
        saveRemote: (user, lesson) async => uploaded.add('$user:$lesson'),
      );
      await controller.activate('A');
      expect(controller.completed, {'py-02'});
      expect(controller.syncFailed, true);
      await controller.complete('py-04', expectedUser: 'A');
      offline = false;
      await controller.sync();
      expect(controller.completed, {'py-02', 'py-03', 'py-04'});
      expect(uploaded, ['A:py-02', 'A:py-04']);
      expect(prefs.getStringList('completed_lessons'), ['py-01']);
      controller.dispose();
    },
  );
  test(
    'Late account A response never changes account B state or cache',
    () async {
      SharedPreferences.setMockInitialValues({
        'completed_B': ['py-02'],
      });
      final prefs = await SharedPreferences.getInstance();
      final delayed = Completer<Set<String>>();
      final controller = ProgressController(
        prefs: prefs,
        loadRemote: (id) =>
            id == 'A' ? delayed.future : Future.value({'py-02'}),
        saveRemote: (_, _) async {},
      );
      final first = controller.activate('A');
      await Future<void>.delayed(Duration.zero);
      final second = controller.activate('B');
      expect(controller.completed, {'py-02'});
      delayed.complete({'py-01'});
      await Future.wait([first, second]);
      expect(controller.user, 'B');
      expect(controller.completed, {'py-02'});
      expect(prefs.getStringList('completed_B'), ['py-02']);
      expect(prefs.getStringList('completed_A'), isNull);
      await expectLater(
        controller.complete('py-09', expectedUser: 'A'),
        throwsA(isA<AccountChanged>()),
      );
      controller.dispose();
    },
  );
  test('Concurrent completions are persisted without lost updates', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = ProgressController(
      prefs: prefs,
      loadRemote: (_) async => {},
      saveRemote: (_, _) async {},
    );
    await controller.activate(null);
    await Future.wait([
      controller.complete('py-01', expectedUser: null),
      controller.complete('py-02', expectedUser: null),
    ]);
    expect(controller.completed, {'py-01', 'py-02'});
    controller.dispose();
  });
}
