import 'dart:async';
import 'package:flutter/widgets.dart';

class StudyCheckpoint {
  final String checkpointId;
  final String accountScope;
  final String lessonId;
  final String activityType;
  final int foregroundSeconds;
  final DateTime startedAt;
  final DateTime endedAt;
  final bool completedReading;
  final bool syncedToCloud;

  const StudyCheckpoint({
    required this.checkpointId,
    required this.accountScope,
    required this.lessonId,
    required this.activityType,
    required this.foregroundSeconds,
    required this.startedAt,
    required this.endedAt,
    this.completedReading = false,
    this.syncedToCloud = false,
  });

  StudyCheckpoint copyWith({bool? syncedToCloud, bool? completedReading}) {
    return StudyCheckpoint(
      checkpointId: checkpointId,
      accountScope: accountScope,
      lessonId: lessonId,
      activityType: activityType,
      foregroundSeconds: foregroundSeconds,
      startedAt: startedAt,
      endedAt: endedAt,
      completedReading: completedReading ?? this.completedReading,
      syncedToCloud: syncedToCloud ?? this.syncedToCloud,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'checkpoint_id': checkpointId,
        'account_scope': accountScope,
        'lesson_id': lessonId,
        'activity_type': activityType,
        'foreground_seconds': foregroundSeconds,
        'started_at': startedAt.toUtc().toIso8601String(),
        'ended_at': endedAt.toUtc().toIso8601String(),
        'completed_reading': completedReading,
        'synced_to_cloud': syncedToCloud,
      };

  factory StudyCheckpoint.fromJson(Map<String, dynamic> json) {
    return StudyCheckpoint(
      checkpointId: (json['checkpoint_id'] as String?) ?? '',
      accountScope: (json['account_scope'] as String?) ?? 'guest',
      lessonId: (json['lesson_id'] as String?) ?? '',
      activityType: (json['activity_type'] as String?) ?? 'lesson_reading',
      foregroundSeconds: (json['foreground_seconds'] as num?)?.toInt() ?? 0,
      startedAt: DateTime.tryParse((json['started_at'] as String?) ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      endedAt: DateTime.tryParse((json['ended_at'] as String?) ?? '')?.toUtc() ??
          DateTime.now().toUtc(),
      completedReading: json['completed_reading'] == true,
      syncedToCloud: json['synced_to_cloud'] == true,
    );
  }
}

class StudyTracker with WidgetsBindingObserver {
  final Future<void> Function(StudyCheckpoint checkpoint) onCheckpointReady;

  String _accountScope;
  String? _activeLessonId;
  String _activityType = 'lesson_reading';
  DateTime? _segmentStartedAt;
  int _accumulatedSeconds = 0;
  bool _isRunning = false;
  Timer? _ticker;
  int _checkpointSequence = 0;

  StudyTracker({
    required String initialAccountScope,
    required this.onCheckpointReady,
  }) : _accountScope = initialAccountScope;

  String get accountScope => _accountScope;
  bool get isRunning => _isRunning;
  int get currentSessionSeconds => _accumulatedSeconds;
  String? get activeLessonId => _activeLessonId;

  void startSession({
    required String lessonId,
    String activityType = 'lesson_reading',
  }) {
    if (_activeLessonId != null && _activeLessonId != lessonId) {
      flushCheckpoint();
    }
    _activeLessonId = lessonId;
    _activityType = activityType;
    _resumeTimer();
  }

  void _resumeTimer() {
    if (_isRunning || _activeLessonId == null) return;
    _isRunning = true;
    _segmentStartedAt ??= DateTime.now().toUtc();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isRunning) {
        _accumulatedSeconds += 1;
      }
    });
  }

  void pauseSession() {
    if (!_isRunning) return;
    _isRunning = false;
    _ticker?.cancel();
    _ticker = null;
  }

  Future<StudyCheckpoint?> flushCheckpoint({bool completedReading = false}) async {
    pauseSession();
    final String? lessonId = _activeLessonId;
    if (lessonId == null || _accumulatedSeconds <= 0) {
      _accumulatedSeconds = 0;
      _segmentStartedAt = null;
      return null;
    }

    final DateTime endedAt = DateTime.now().toUtc();
    final DateTime startedAt = _segmentStartedAt ??
        endedAt.subtract(Duration(seconds: _accumulatedSeconds));
    _checkpointSequence += 1;

    final String checkpointId =
        'chk_${_accountScope}_${lessonId}_${startedAt.millisecondsSinceEpoch}_$_checkpointSequence';

    final StudyCheckpoint checkpoint = StudyCheckpoint(
      checkpointId: checkpointId,
      accountScope: _accountScope,
      lessonId: lessonId,
      activityType: _activityType,
      foregroundSeconds: _accumulatedSeconds,
      startedAt: startedAt,
      endedAt: endedAt,
      completedReading: completedReading,
    );

    _accumulatedSeconds = 0;
    _segmentStartedAt = null;

    await onCheckpointReady(checkpoint);
    return checkpoint;
  }

  Future<void> switchAccountScope(String newAccountScope) async {
    if (newAccountScope == _accountScope) return;
    await flushCheckpoint();
    _activeLessonId = null;
    _accountScope = newAccountScope;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_activeLessonId != null) {
        _resumeTimer();
      }
    } else if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.hidden) {
      unawaited(flushCheckpoint());
    }
  }

  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    _isRunning = false;
  }
}
