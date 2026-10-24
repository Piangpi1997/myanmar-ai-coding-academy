import 'dart:math';

import 'study_store.dart';

/// Measures only explicit foreground intervals; the widget pauses it on lifecycle changes.
class StudyTracker {
  StudyTracker({DateTime Function()? now, String Function()? idFactory})
    : _now = now ?? DateTime.now,
      _idFactory = idFactory ?? _uuidV4;

  final DateTime Function() _now;
  final String Function() _idFactory;
  DateTime? _segmentStartedAt;
  int _savedSeconds = 0;
  bool _running = false;
  String _activity = 'lesson';
  String? _lessonId;

  bool get isRunning => _running;

  int get elapsedSeconds {
    if (!_running || _segmentStartedAt == null) return _savedSeconds;
    final seconds = _now().difference(_segmentStartedAt!).inSeconds;
    return _savedSeconds + (seconds < 0 ? 0 : seconds);
  }

  int get currentSegmentSeconds {
    if (!_running || _segmentStartedAt == null) return 0;
    final seconds = _now().difference(_segmentStartedAt!).inSeconds;
    return seconds < 0 ? 0 : seconds;
  }

  void start({String activity = 'lesson', String? lessonId}) {
    if (_running) return;
    _savedSeconds = 0;
    _activity = activity;
    _lessonId = lessonId;
    _segmentStartedAt = _now();
    _running = true;
  }

  /// Saves an idempotent checkpoint; a repeated call within the same second is a no-op.
  StudySession? checkpoint() {
    if (!_running || _segmentStartedAt == null) return null;
    final now = _now();
    final elapsed = now.difference(_segmentStartedAt!).inSeconds;
    final seconds = elapsed < 0 ? 0 : elapsed;
    if (seconds == 0) return null;
    final startedAt = _segmentStartedAt!;
    _savedSeconds += seconds;
    _segmentStartedAt = now;
    return StudySession(
      clientId: _idFactory(),
      startedAt: startedAt,
      durationSeconds: seconds,
      activity: _activity,
      lessonId: _lessonId,
    );
  }

  StudySession? stop() {
    if (!_running) return null;
    final last = checkpoint();
    _running = false;
    _segmentStartedAt = null;
    _savedSeconds = 0;
    _lessonId = null;
    return last;
  }

  static String _uuidV4() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
