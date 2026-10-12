import 'dart:convert';
import '../../core/secure_store.dart';

class ProjectRecord {
  const ProjectRecord({this.completed = const {}, this.notes = ''});
  final Set<String> completed;
  final String notes;
  Map<String, dynamic> toJson() => {
    'completed': completed.toList(),
    'notes': notes,
  };
}

class ProjectStore {
  static String key(String? account, String project) =>
      'project.v1.${account ?? 'guest'}.$project';
  static Future<ProjectRecord> load(
    String? account,
    String project,
    Set<String> validSteps,
  ) async {
    final raw = await secureStorage.read(key: key(account, project));
    if (raw == null) return const ProjectRecord();
    final data = jsonDecode(raw) as Map;
    final completed = List<String>.from(
      data['completed'] as List,
    ).toSet().intersection(validSteps);
    final notes = data['notes'] as String;
    if (notes.length > 2000) throw const FormatException('Invalid notes');
    return ProjectRecord(completed: completed, notes: notes);
  }

  static Future<void> save(
    String? account,
    String project,
    ProjectRecord record,
  ) {
    if (record.notes.length > 2000) {
      throw const FormatException('Notes too long');
    }
    return secureStorage.write(
      key: key(account, project),
      value: jsonEncode(record.toJson()),
    );
  }
}
