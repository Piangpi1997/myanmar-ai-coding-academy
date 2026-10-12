import 'dart:math';

String submissionId() {
  final random = Random.secure();
  final bytes = List.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 15) | 64;
  bytes[8] = (bytes[8] & 63) | 128;
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

class GradeResult {
  GradeResult.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      exercise = json['exercise_id'] as String,
      state = json['state'] as String,
      feedback = json['feedback'] as String,
      passed = json['passed_count'] as int,
      total = json['total_count'] as int {
    if (!RegExp(
          r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
        ).hasMatch(id) ||
        !['pending', 'complete', 'error'].contains(state) ||
        ![
          'pending',
          'passed',
          'wrong_answer',
          'runtime_error',
          'timeout',
          'output_limit',
          'service_unavailable',
        ].contains(feedback) ||
        total < 1 ||
        total > 3 ||
        passed < 0 ||
        passed > total ||
        (feedback == 'passed' && passed != total) ||
        (state == 'pending' && (feedback != 'pending' || passed != 0)) ||
        (state == 'complete' &&
            ![
              'passed',
              'wrong_answer',
              'runtime_error',
              'timeout',
              'output_limit',
            ].contains(feedback)) ||
        (state == 'error' &&
            !['timeout', 'service_unavailable'].contains(feedback))) {
      throw const FormatException('Invalid assessment result');
    }
  }
  final String id, exercise, state, feedback;
  final int passed, total;
  Map<String, dynamic> toJson() => {
    'id': id,
    'exercise_id': exercise,
    'state': state,
    'feedback': feedback,
    'passed_count': passed,
    'total_count': total,
  };
}
