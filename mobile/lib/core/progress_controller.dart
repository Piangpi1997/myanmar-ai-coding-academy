import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef LoadRemote = Future<Set<String>> Function(String user);
typedef SaveRemote = Future<void> Function(String user, String lesson);

/// Monotonic lesson completion. Guest and every user have separate local namespaces.
class ProgressController extends ChangeNotifier {
  ProgressController({
    required this.prefs,
    required this.loadRemote,
    required this.saveRemote,
  });
  final SharedPreferences prefs;
  final LoadRemote loadRemote;
  final SaveRemote saveRemote;
  String? user;
  Set<String> completed = {};
  bool syncing = false;
  bool syncFailed = false;
  bool _disposed = false;
  int _generation = 0;
  Future<void> _queue = Future.value();
  String _key(String? id) => id == null ? 'completed_lessons' : 'completed_$id';
  bool _active(int generation) => !_disposed && generation == _generation;
  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _enqueue(Future<void> Function() action) {
    final next = _queue.then((_) => action());
    _queue = next.catchError((Object _) {});
    return next;
  }

  Future<void> activate(String? id) {
    user = id;
    final generation = ++_generation;
    completed = prefs.getStringList(_key(id))?.toSet() ?? {};
    syncing = false;
    syncFailed = false;
    _notify();
    return _enqueue(() => _sync(id, generation));
  }

  Future<void> complete(String lesson, {required String? expectedUser}) {
    if (expectedUser != user) return Future.error(const AccountChanged());
    final id = user;
    final generation = _generation;
    return _enqueue(() async {
      if (!_active(generation)) throw const AccountChanged();
      final next = <String>{
        ...(prefs.getStringList(_key(id)) ?? <String>[]),
        lesson,
      };
      await prefs.setStringList(_key(id), next.toList());
      if (_active(generation)) {
        completed = next;
        _notify();
      }
      await _sync(id, generation);
    });
  }

  Future<void> sync() {
    final id = user;
    final generation = _generation;
    return _enqueue(() => _sync(id, generation));
  }

  Future<void> _sync(String? id, int generation) async {
    if (id == null || !_active(generation)) return;
    syncing = true;
    syncFailed = false;
    _notify();
    try {
      final remote = await loadRemote(id);
      if (!_active(generation)) return;
      final local = prefs.getStringList(_key(id))?.toSet() ?? <String>{};
      // Only this user's unsynced completions are uploaded. Repeated PUTs are idempotent.
      for (final lesson in local.difference(remote)) {
        if (!_active(generation)) return;
        await saveRemote(id, lesson);
      }
      if (!_active(generation)) return;
      final merged = {...remote, ...local};
      await prefs.setStringList(_key(id), merged.toList());
      if (_active(generation)) completed = merged;
    } catch (_) {
      if (_active(generation)) syncFailed = true;
    } finally {
      if (_active(generation)) {
        syncing = false;
        _notify();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

class AccountChanged implements Exception {
  const AccountChanged();
}
