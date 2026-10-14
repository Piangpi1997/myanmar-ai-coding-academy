import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class StudySession {
  const StudySession({
    required this.clientId,
    required this.startedAt,
    required this.durationSeconds,
    required this.activity,
    this.lessonId,
    this.synced = false,
  });

  final String clientId;
  final DateTime startedAt;
  final int durationSeconds;
  final String activity;
  final String? lessonId;
  final bool synced;

  StudySession copyWith({bool? synced}) => StudySession(
    clientId: clientId,
    startedAt: startedAt,
    durationSeconds: durationSeconds,
    activity: activity,
    lessonId: lessonId,
    synced: synced ?? this.synced,
  );

  Map<String, dynamic> toLocalJson() => {
    ...toApiJson(),
    'synced': synced,
  };

  Map<String, dynamic> toApiJson() => {
    'client_id': clientId,
    'started_at': startedAt.toUtc().toIso8601String(),
    'duration_seconds': durationSeconds,
    'activity': activity,
    'lesson_id': lessonId,
  };

  factory StudySession.fromJson(Map<String, dynamic> json, {bool? synced}) =>
      StudySession(
        clientId: json['client_id'] as String,
        startedAt: DateTime.parse(json['started_at'] as String).toUtc(),
        durationSeconds: (json['duration_seconds'] as num).toInt(),
        activity: json['activity'] as String,
        lessonId: json['lesson_id'] as String?,
        synced: synced ?? json['synced'] == true,
      );
}

class StudySyncResult {
  const StudySyncResult({required this.sessions, required this.hadError});
  final List<StudySession> sessions;
  final bool hadError;
}

typedef LoadStudyRemote = Future<List<Map<String, dynamic>>> Function(String owner);
typedef SaveStudyRemote = Future<void> Function(
  String owner,
  Map<String, dynamic> session,
);

/// Local owner-scoped history is written before any network request. Failed
/// cloud writes remain queued locally and can be retried without duplicating rows.
class StudyStore {
  StudyStore(
    this.prefs, {
    this.loadRemote,
    this.saveRemote,
  });

  final SharedPreferences prefs;
  final LoadStudyRemote? loadRemote;
  final SaveStudyRemote? saveRemote;

  static String storageKey(String? owner) => 'study.v1.${owner ?? 'guest'}';

  List<StudySession> read(String? owner) {
    final raw = prefs.getString(storageKey(owner));
    if (raw == null) return [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) throw const FormatException('Invalid study history');
    return decoded.map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return StudySession.fromJson(map, synced: map['synced'] == true);
    }).toList();
  }

  Future<void> write(String? owner, List<StudySession> sessions) async {
    final bounded = [...sessions]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final serialized = bounded.map((item) => item.toLocalJson()).toList();
    if (!await prefs.setString(storageKey(owner), jsonEncode(serialized))) {
      throw StateError('Could not save study history');
    }
  }

  Future<List<StudySession>> append(String? owner, StudySession session) async {
    final current = read(owner);
    if (!current.any((item) => item.clientId == session.clientId)) {
      current.add(session);
    }
    await write(owner, current);
    return read(owner);
  }

  Future<StudySyncResult> sync(String owner) async {
    final local = read(owner);
    if (loadRemote == null || saveRemote == null) {
      return StudySyncResult(sessions: local, hadError: true);
    }

    List<StudySession> remote;
    try {
      remote = (await loadRemote!(owner))
          .map((item) => StudySession.fromJson(item, synced: true))
          .toList();
    } catch (_) {
      return StudySyncResult(sessions: local, hadError: true);
    }

    var hadError = false;
    for (var index = 0; index < local.length; index++) {
      final session = local[index];
      if (session.synced) continue;
      try {
        await saveRemote!(owner, session.toApiJson());
        local[index] = session.copyWith(synced: true);
      } catch (_) {
        hadError = true;
      }
    }

    final mergedById = <String, StudySession>{
      for (final item in remote) item.clientId: item,
    };
    for (final item in local) {
      final serverCopy = mergedById[item.clientId];
      if (serverCopy == null) {
        mergedById[item.clientId] = item;
        continue;
      }
      final matches = serverCopy.startedAt.isAtSameMomentAs(item.startedAt) &&
          serverCopy.durationSeconds == item.durationSeconds &&
          serverCopy.activity == item.activity &&
          serverCopy.lessonId == item.lessonId;
      if (!matches) {
        hadError = true;
        mergedById[item.clientId] = item;
      }
    }
    final merged = mergedById.values.toList();
    await write(owner, merged);
    return StudySyncResult(sessions: read(owner), hadError: hadError);
  }
}
