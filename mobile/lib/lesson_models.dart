class Lesson {
  const Lesson({
    required this.id,
    required this.titleMy,
    required this.titleEn,
    required this.summaryMy,
    required this.bodyMy,
    required this.code,
    required this.challengeMy,
    required this.answer,
    this.level = 'beginner',
    this.environment = 'sandbox',
    this.prerequisites = const [],
    this.flow = const [],
  });

  final String id;
  final String titleMy;
  final String titleEn;
  final String summaryMy;
  final String bodyMy;
  final String code;
  final String challengeMy;
  final String answer;
  final String level, environment;
  final List<String> prerequisites, flow;
}

// Original bilingual beginner guides. References explain concepts; text is authored for this app.
class LessonGuide {
  const LessonGuide({
    required this.my,
    required this.en,
    required this.myOptions,
    required this.enOptions,
    required this.correct,
    required this.reference,
  });
  final Map<String, String> my, en;
  final List<String> myOptions, enOptions;
  final int correct;
  final String reference;
  Map<String, String> text(bool english) => english ? en : my;
  List<String> options(bool english) => english ? enOptions : myOptions;
}
