import 'dart:convert';
import 'reminder_preferences.dart';
import 'study_tracker.dart';

abstract class KeyValueStorage {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class InMemoryKeyValueStorage implements KeyValueStorage {
  final Map<String, String> _map = <String, String>{};

  @override
  Future<String?> getString(String key) async => _map[key];

  @override
  Future<void> setString(String key, String value) async {
    _map[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _map.remove(key);
  }
}

class StudyStore {
  final KeyValueStorage _storage;
  final Future<bool> Function(StudyCheckpoint checkpoint)? _cloudSyncCallback;

  StudyStore({
    required KeyValueStorage storage,
    Future<bool> Function(StudyCheckpoint checkpoint)? cloudSyncCallback,
  })  : _storage = storage,
        _cloudSyncCallback = cloudSyncCallback;

  String _checkpointsKey(String scope) => 'study_checkpoints_v1_$scope';
  String _reminderKey(String scope) => 'study_reminders_v1_$scope';

  Future<List<StudyCheckpoint>> saveCheckpoint(StudyCheckpoint checkpoint) async {
    final String scope = checkpoint.accountScope;
    final List<StudyCheckpoint> existing = await loadCheckpoints(scope);
    final int idx = existing.indexWhere(
      (StudyCheckpoint c) => c.checkpointId == checkpoint.checkpointId,
    );

    StudyCheckpoint toStore = checkpoint;
    if (_cloudSyncCallback != null && scope != 'guest') {
      try {
        final bool synced = await _cloudSyncCallback!(checkpoint);
        toStore = checkpoint.copyWith(syncedToCloud: synced);
      } catch (_) {
        toStore = checkpoint.copyWith(syncedToCloud: false);
      }
    }

    if (idx >= 0) {
      existing[idx] = toStore;
    } else {
      existing.add(toStore);
    }

    await _persistCheckpoints(scope, existing);
    return existing;
  }

  Future<int> retryPendingSyncs(String scope) async {
    if (scope == 'guest' || _cloudSyncCallback == null) return 0;
    final List<StudyCheckpoint> list = await loadCheckpoints(scope);
    int syncedCount = 0;
    bool modified = false;

    for (int i = 0; i < list.length; i++) {
      final StudyCheckpoint item = list[i];
      if (!item.syncedToCloud) {
        try {
          final bool ok = await _cloudSyncCallback!(item);
          if (ok) {
            list[i] = item.copyWith(syncedToCloud: true);
            syncedCount += 1;
            modified = true;
          }
        } catch (_) {}
      }
    }

    if (modified) {
      await _persistCheckpoints(scope, list);
    }
    return syncedCount;
  }

  Future<List<StudyCheckpoint>> loadCheckpoints(String scope) async {
    final String? raw = await _storage.getString(_checkpointsKey(scope));
    if (raw == null || raw.isEmpty) return <StudyCheckpoint>[];
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map<String, dynamic>>()
            .map(StudyCheckpoint.fromJson)
            .toList();
      }
    } catch (_) {}
    return <StudyCheckpoint>[];
  }

  Future<void> _persistCheckpoints(
      String scope, List<StudyCheckpoint> checkpoints) async {
    final String encoded = jsonEncode(
      checkpoints.map((StudyCheckpoint c) => c.toJson()).toList(),
    );
    await _storage.setString(_checkpointsKey(scope), encoded);
  }

  Future<int> getTotalStudySeconds(String scope) async {
    final List<StudyCheckpoint> list = await loadCheckpoints(scope);
    return list.fold<int>(
        0, (int sum, StudyCheckpoint c) => sum + c.foregroundSeconds);
  }

  Future<Set<String>> getReadingCompletedLessonIds(String scope) async {
    final List<StudyCheckpoint> list = await loadCheckpoints(scope);
    return list
        .where((StudyCheckpoint c) => c.completedReading)
        .map((StudyCheckpoint c) => c.lessonId)
        .toSet();
  }

  Future<ReminderPreferences> loadReminderPreferences(String scope) async {
    final String? raw = await _storage.getString(_reminderKey(scope));
    if (raw == null || raw.isEmpty) {
      return ReminderPreferences(accountScope: scope);
    }
    return ReminderPreferences.decode(raw, scope: scope);
  }

  Future<void> saveReminderPreferences(ReminderPreferences prefs) async {
    await _storage.setString(
      _reminderKey(prefs.accountScope),
      prefs.encode(),
    );
  }
}
