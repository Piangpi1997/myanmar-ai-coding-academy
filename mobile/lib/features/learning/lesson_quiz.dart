import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../cloud_service.dart';
import '../../lesson_guides.dart';
import '../../l10n/generated/app_localizations.dart';

/// Public self-check questions, not private code-grading tests or certification.
class LessonQuiz extends StatefulWidget {
  const LessonQuiz({
    super.key,
    required this.lessonId,
    required this.guide,
    required this.english,
  });
  final String lessonId;
  final LessonGuide guide;
  final bool english;
  @override
  State<LessonQuiz> createState() => _LessonQuizState();
}

class _LessonQuizState extends State<LessonQuiz> {
  late final String? account;
  String get storageKey => 'quiz.v1.${account ?? 'guest'}.${widget.lessonId}';
  int? selected;
  int? checked;
  int attempts = 0;
  bool loading = true;
  String? error;
  @override
  void initState() {
    super.initState();
    account = CloudService.user?.id;
    restore();
  }

  Future<void> restore() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      attempts = prefs.getInt('$storageKey.attempts') ?? 0;
      final value = prefs.getInt('$storageKey.answer');
      if (value != null &&
          value >= 0 &&
          value < widget.guide.myOptions.length) {
        selected = checked = value;
      }
    } catch (_) {
      /* A failed restore leaves a usable, ungraded question. */
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> check() async {
    if (selected == null || loading) return;
    final l = AppLocalizations.of(context)!;
    if (CloudService.user?.id != account) {
      setState(() => error = l.sessionExpired);
      return;
    }
    setState(() {
      loading = true;
      checked = selected;
      attempts++;
      error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setInt('$storageKey.answer', checked!);
      final savedAttempts = await prefs.setInt(
        '$storageKey.attempts',
        attempts,
      );
      if (!saved || !savedAttempts) throw StateError('Local write failed');
    } catch (_) {
      if (mounted) setState(() => error = l.storageError);
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final text = widget.guide.text(widget.english);
    final options = widget.guide.options(widget.english);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.quickQuiz, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(text['question']!),
            for (var i = 0; i < options.length; i++)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: loading
                      ? null
                      : () => setState(() {
                          selected = i;
                          checked = null;
                          error = null;
                        }),
                  icon: Icon(
                    selected == i
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                  ),
                  label: Text(options[i]),
                ),
              ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: selected == null || loading ? null : check,
              child: Text(l.checkAnswer),
            ),
            if (checked != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '${checked == widget.guide.correct ? l.correctAnswer : l.tryAgain}\n${text['explanation']}',
                ),
              ),
            Text(
              widget.english
                  ? 'Local attempts: $attempts'
                  : 'စက်တွင်း ဖြေဆိုမှု: $attempts',
            ),
            if (error != null) Text(error!),
          ],
        ),
      ),
    );
  }
}
