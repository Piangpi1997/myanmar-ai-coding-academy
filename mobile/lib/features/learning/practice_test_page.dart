import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../cloud_service.dart';
import '../../lessons.dart';
import '../../lesson_guides.dart';
import 'academy_tracks.dart';

class PracticeRun {
  PracticeRun(List<Lesson> source, {required int count, Random? random}) {
    if (source.isEmpty) throw ArgumentError('Question bank is empty');
    final shuffled = [...source]..shuffle(random ?? Random());
    questions = List.unmodifiable(
      shuffled.take(count.clamp(1, shuffled.length)),
    );
  }
  late final List<Lesson> questions;
  final Map<String, int> answers = {};
  bool get complete => questions.every((q) => answers.containsKey(q.id));
  int get score => questions
      .where((q) => answers[q.id] == lessonGuides[q.id]!.correct)
      .length;
  void answer(String id, int value) {
    if (!questions.any((q) => q.id == id)) {
      throw ArgumentError('Unknown question');
    }
    if (value < 0 || value >= lessonGuides[id]!.enOptions.length) {
      throw ArgumentError('Invalid answer');
    }
    answers[id] = value;
  }
}

class PracticeHistory {
  PracticeHistory(this.prefs);
  final SharedPreferences prefs;
  static String key(String? account) =>
      'practice_tests.v1.${account ?? 'guest'}';
  List<Map<String, dynamic>> read(String? account) {
    final raw = prefs.getString(key(account));
    if (raw == null) return [];
    final parsed = jsonDecode(raw);
    if (parsed is! List) {
      throw const FormatException('Unreadable practice history');
    }
    return parsed.map((row) {
      if (row is! Map ||
          row['score'] is! int ||
          row['total'] is! int ||
          row['at'] is! String ||
          row['track'] is! String ||
          !['all', ...academyTracks].contains(row['track']) ||
          (row['total'] as int) < 1 ||
          (row['total'] as int) > 20 ||
          (row['score'] as int) < 0 ||
          (row['score'] as int) > (row['total'] as int) ||
          DateTime.tryParse(row['at'] as String) == null) {
        throw const FormatException('Unreadable practice history');
      }
      return Map<String, dynamic>.from(row);
    }).toList();
  }

  Future<void> save(String? account, PracticeRun run, String track) async {
    if (!run.complete) throw StateError('Test incomplete');
    final entries = read(account);
    entries.insert(0, {
      'score': run.score,
      'total': run.questions.length,
      'track': track,
      'at': DateTime.now().toUtc().toIso8601String(),
    });
    if (!await prefs.setString(
      key(account),
      jsonEncode(entries.take(60).toList()),
    )) {
      throw StateError('Save failed');
    }
  }
}

class PracticeTestPage extends StatefulWidget {
  const PracticeTestPage({
    super.key,
    required this.account,
    required this.english,
  });
  final String? account;
  final bool english;
  @override
  State<PracticeTestPage> createState() => _PracticeTestPageState();
}

class _PracticeTestPageState extends State<PracticeTestPage> {
  String track = 'all';
  int count = 10, index = 0;
  bool preview = false, submitted = false, saving = false;
  PracticeRun? run;
  PracticeHistory? store;
  List<Map<String, dynamic>> history = [];
  String? notice;
  String t(String my, String en) => widget.english ? en : my;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final loaded = PracticeHistory(await SharedPreferences.getInstance());
      final rows = loaded.read(widget.account);
      if (!mounted) return;
      setState(() {
        store = loaded;
        history = rows;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => notice = t(
            'မှတ်တမ်းဟောင်း ဖတ်မရပါ။ မူရင်းကို မပြင်ထားပါ။',
            'History could not be read; the stored data is preserved.',
          ),
        );
      }
    }
  }

  void prepare(bool showPreview) {
    setState(() {
      run = PracticeRun(
        academyLessons
            .where((q) => track == 'all' || q.track == track)
            .toList(),
        count: count,
      );
      index = 0;
      submitted = false;
      preview = showPreview;
    });
  }

  Future<void> finish() async {
    if (saving || run == null || !run!.complete) return;
    setState(() {
      submitted = true;
      saving = true;
    });
    try {
      if (CloudService.user?.id != widget.account) {
        throw StateError('Account changed');
      }
      if (store == null) throw StateError('Storage unavailable');
      await store!.save(widget.account, run!, track);
      if (mounted) setState(() => history = store!.read(widget.account));
    } catch (_) {
      if (mounted) {
        setState(
          () => notice = t(
            'ရလဒ်ကို ပြထားသည်။ Device မှတ်တမ်းကို မသိမ်းနိုင်သေးပါ။',
            'Result shown; it could not be saved to device history.',
          ),
        );
      }
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = run;
    return Scaffold(
      appBar: AppBar(title: Text(t('Q&A စမ်းသပ်ခန်း', 'Q&A Practice'))),
      body: current == null
          ? _setup()
          : preview
          ? _preview(current)
          : submitted
          ? _result(current)
          : _question(current),
    );
  }

  Widget _setup() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const Icon(Icons.quiz_outlined, size: 44),
      const SizedBox(height: 14),
      Text(
        t('သင်ယူပြီး စမ်းဖြေပါ', 'Practice what you learn'),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: 8),
      Text(
        t(
          'ဘာသာရပ်ရွေး၊ မေးခွန်းကြိုကြည့်၊ စမ်းဖြေပြီး အဖြေရှင်းလင်းချက် ဖတ်ပါ။',
          'Choose a subject, preview the questions, then take a test and review explanations.',
        ),
      ),
      const SizedBox(height: 22),
      DropdownButtonFormField<String>(
        initialValue: track,
        decoration: InputDecoration(labelText: t('ဘာသာရပ်', 'Subject')),
        items: ['all', ...academyTracks]
            .map(
              (v) => DropdownMenuItem(
                value: v,
                child: Text(trackLabel(v, widget.english)),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => track = v ?? 'all'),
      ),
      const SizedBox(height: 14),
      DropdownButtonFormField<int>(
        initialValue: count,
        decoration: InputDecoration(
          labelText: t('မေးခွန်းအရေအတွက်', 'Questions'),
        ),
        items: [
          5,
          10,
          20,
        ].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
        onChanged: (v) => setState(() => count = v ?? 10),
      ),
      const SizedBox(height: 20),
      FilledButton.icon(
        onPressed: () => prepare(false),
        icon: const Icon(Icons.play_arrow),
        label: Text(t('စမ်းဖြေမယ်', 'Start test')),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: () => prepare(true),
        icon: const Icon(Icons.preview_outlined),
        label: Text(t('မေးခွန်းကြိုကြည့်ရန်', 'Test preview')),
      ),
      const SizedBox(height: 18),
      Text(
        t(
          'ကိုယ်တိုင်လေ့ကျင့်ရန်သာ ဖြစ်သည်။ Certification စာမေးပွဲ မဟုတ်ပါ။ မှတ်တမ်းကို ဤ device ပေါ်တွင် သိမ်းသည်။',
          'A self-check, not a certification exam. History is stored on this device.',
        ),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      if (notice != null) Text(notice!),
      if (history.isNotEmpty) ...[
        const SizedBox(height: 24),
        Text(
          t('လတ်တလောရလဒ်', 'Recent results'),
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final row in history.take(5))
          Card(
            child: ListTile(
              leading: const Icon(Icons.fact_check_outlined),
              title: Text('${row['score']} / ${row['total']}'),
              subtitle: Text(
                '${trackLabel(row['track'] as String? ?? 'all', widget.english)} · ${(row['at'] as String).split('T').first}',
              ),
            ),
          ),
      ],
    ],
  );
  Widget _preview(PracticeRun value) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text(
        t('မေးခွန်းကြိုကြည့်ခြင်း', 'Question preview'),
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      Text(
        t(
          'စမ်းဖြေမပြီးမီ အဖြေမှန် မပြထားပါ။',
          'Correct answers are shown after submission.',
        ),
      ),
      for (var i = 0; i < value.questions.length; i++)
        Card(
          child: ExpansionTile(
            title: Text(
              '${i + 1}. ${lessonGuides[value.questions[i].id]!.text(widget.english)['question']}',
            ),
            children: [
              for (final option in lessonGuides[value.questions[i].id]!.options(
                widget.english,
              ))
                ListTile(title: Text(option)),
            ],
          ),
        ),
      FilledButton(
        onPressed: () => setState(() => preview = false),
        child: Text(t('ဤမေးခွန်းများ စမ်းဖြေမယ်', 'Start these questions')),
      ),
      TextButton(
        onPressed: () => setState(() => run = null),
        child: Text(t('ဘာသာရပ် ပြန်ရွေးရန်', 'Back to setup')),
      ),
    ],
  );
  Widget _question(PracticeRun value) {
    final lesson = value.questions[index];
    final guide = lessonGuides[lesson.id]!;
    final options = guide.options(widget.english);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${index + 1} / ${value.questions.length} · ${trackLabel(lesson.track, widget.english)}',
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: value.answers.length / value.questions.length,
        ),
        const SizedBox(height: 24),
        Text(
          guide.text(widget.english)['question']!,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 18),
        for (var i = 0; i < options.length; i++)
          Card(
            color: value.answers[lesson.id] == i
                ? Theme.of(context).colorScheme.primaryContainer
                : null,
            child: ListTile(
              key: ValueKey('answer.$i'),
              leading: Icon(
                value.answers[lesson.id] == i
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(options[i]),
              onTap: () => setState(() => value.answer(lesson.id, i)),
            ),
          ),
        const SizedBox(height: 20),
        Row(
          children: [
            TextButton(
              onPressed: index == 0 ? null : () => setState(() => index--),
              child: Text(t('ရှေ့သို့', 'Previous')),
            ),
            const Spacer(),
            FilledButton(
              onPressed: index == value.questions.length - 1
                  ? null
                  : () => setState(() => index++),
              child: Text(t('နောက်သို့', 'Next')),
            ),
          ],
        ),
        if (index == value.questions.length - 1)
          FilledButton.icon(
            onPressed: value.complete ? finish : null,
            icon: const Icon(Icons.check),
            label: Text(t('အဖြေတင်ပြီး ရလဒ်ကြည့်ရန်', 'Submit test')),
          ),
        Text(
          t(
            'ဖြေပြီး ${value.answers.length} / ${value.questions.length}',
            'Answered ${value.answers.length} / ${value.questions.length}',
          ),
        ),
      ],
    );
  }

  Widget _result(PracticeRun value) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const Icon(Icons.task_alt, size: 44),
              Text(
                '${value.score} / ${value.questions.length}',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              Text(t('စမ်းဖြေမှု ရလဒ်', 'Practice result')),
            ],
          ),
        ),
      ),
      if (notice != null) Text(notice!),
      for (final lesson in value.questions)
        Card(
          child: ExpansionTile(
            leading: Icon(
              value.answers[lesson.id] == lessonGuides[lesson.id]!.correct
                  ? Icons.check_circle_outline
                  : Icons.refresh,
            ),
            title: Text(
              lessonGuides[lesson.id]!.text(widget.english)['question']!,
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t('သင့်အဖြေ', 'Your answer')}: ${lessonGuides[lesson.id]!.options(widget.english)[value.answers[lesson.id]!]}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${t('အဖြေမှန်', 'Correct answer')}: ${lessonGuides[lesson.id]!.options(widget.english)[lessonGuides[lesson.id]!.correct]}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      lessonGuides[lesson.id]!.text(
                        widget.english,
                      )['explanation']!,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      FilledButton(
        onPressed: saving
            ? null
            : () => setState(() {
                run = null;
                notice = null;
              }),
        child: Text(t('ထပ်လေ့ကျင့်မယ်', 'Practice again')),
      ),
    ],
  );
}
