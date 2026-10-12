import 'dart:convert';
import 'package:flutter/services.dart';

class LocalizedText {
  LocalizedText(Map<String, dynamic> json)
    : my = json['my'] as String,
      en = json['en'] as String;
  final String my, en;
  String inLanguage(bool english) => english ? en : my;
}

class PracticeExample {
  PracticeExample(Map<String, dynamic> json)
    : stdin = json['stdin'] as String,
      stdout = json['stdout'] as String;
  final String stdin, stdout;
}

class PracticeExercise {
  PracticeExercise(Map<String, dynamic> json)
    : id = json['id'] as String,
      title = LocalizedText(json['title']),
      statement = LocalizedText(json['statement']),
      hint = LocalizedText(json['hint']),
      starter = json['starter'] as String,
      solution = json['solution'] as String,
      lessonIds = List<String>.from(json['lesson_ids']),
      examples = List<PracticeExample>.unmodifiable(
        (json['examples'] as List).map((e) => PracticeExample(e)),
      );
  final String id, starter, solution;
  final LocalizedText title, statement, hint;
  final List<String> lessonIds;
  final List<PracticeExample> examples;
}

class ProjectStep {
  ProjectStep(Map<String, dynamic> json)
    : id = json['id'] as String,
      text = LocalizedText(json['text']);
  final String id;
  final LocalizedText text;
}

class ProjectGuide {
  ProjectGuide(Map<String, dynamic> json)
    : id = json['id'] as String,
      title = LocalizedText(json['title']),
      level = json['level'] as String,
      language = json['language'] as String,
      starter = json['starter'] as String,
      objective = LocalizedText(json['objective']),
      requirements = LocalizedText(json['requirements']),
      architecture = LocalizedText(json['architecture']),
      testing = LocalizedText(json['testing']),
      troubleshooting = LocalizedText(json['troubleshooting']),
      completion = LocalizedText(json['completion']),
      lessonIds = List<String>.from(json['lesson_ids']),
      reference = json['reference'] as String,
      steps = List<ProjectStep>.unmodifiable(
        (json['steps'] as List).map((e) => ProjectStep(e)),
      );
  final String id, level, language, starter, reference;
  final LocalizedText title,
      objective,
      requirements,
      architecture,
      testing,
      troubleshooting,
      completion;
  final List<String> lessonIds;
  final List<ProjectStep> steps;
}

class LearningPath {
  LearningPath(Map<String, dynamic> json)
    : id = json['id'] as String,
      title = LocalizedText(json['title']),
      goal = LocalizedText(json['goal']),
      lessonIds = List<String>.from(json['lesson_ids']),
      exerciseIds = List<String>.from(json['exercise_ids']),
      projectIds = List<String>.from(json['project_ids']);
  final String id;
  final LocalizedText title, goal;
  final List<String> lessonIds, exerciseIds, projectIds;
}

class LearningCatalog {
  LearningCatalog.fromJson(Map<String, dynamic> json) {
    if (json['schema_version'] != 1) {
      throw const FormatException('Unsupported catalog');
    }
    exercises = List<PracticeExercise>.unmodifiable(
      (json['exercises'] as List).map((e) => PracticeExercise(e)),
    );
    projects = List<ProjectGuide>.unmodifiable(
      (json['projects'] as List).map((e) => ProjectGuide(e)),
    );
    paths = List<LearningPath>.unmodifiable(
      (json['paths'] as List).map((e) => LearningPath(e)),
    );
    if (exercises.map((e) => e.id).toSet().length != exercises.length ||
        projects.map((p) => p.id).toSet().length != projects.length ||
        paths.map((p) => p.id).toSet().length != paths.length) {
      throw const FormatException('Duplicate IDs');
    }
  }
  late final List<PracticeExercise> exercises;
  late final List<ProjectGuide> projects;
  late final List<LearningPath> paths;
  static Future<LearningCatalog> load() async => LearningCatalog.fromJson(
    jsonDecode(
          await rootBundle.loadString('assets/learning/learning_catalog.json'),
        )
        as Map<String, dynamic>,
  );
}
