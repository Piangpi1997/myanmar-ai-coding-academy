import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../cloud_service.dart';
import '../../core/messages.dart';
import '../../core/secure_store.dart';
import '../../l10n/generated/app_localizations.dart';
import '../code/python_controller.dart';
import '../code/python_editor.dart';
import 'grade_result.dart';
import 'learning_catalog.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({
    super.key,
    required this.exercise,
    required this.account,
    required this.onTutor,
  });
  final PracticeExercise exercise;
  final String? account;
  final void Function(String) onTutor;
  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  final code = PythonController();
  bool loading = true,
      loadFailed = false,
      busy = false,
      changedAccount = false,
      restored = false;
  int sample = 0;
  String? pendingId, error, notice;
  GradeResult? grade;
  Map<String, dynamic>? output;
  Timer? debounce;
  StreamSubscription? authSubscription;
  Future<void> writes = Future.value();
  String get draftKey =>
      'exercise.v1.${widget.account ?? 'guest'}.${widget.exercise.id}';
  @override
  void initState() {
    super.initState();
    if (CloudService.configured) {
      authSubscription = CloudService.authChanges.listen((_) {
        if (mounted && CloudService.user?.id != widget.account) {
          setState(() => changedAccount = true);
        }
      });
    }
    if (CloudService.user?.id != widget.account) {
      changedAccount = true;
      loading = false;
    } else {
      load();
    }
  }

  Future<void> load() async {
    try {
      final raw = await secureStorage.read(key: draftKey);
      if (!mounted) return;
      if (CloudService.user?.id != widget.account) {
        setState(() {
          changedAccount = true;
          loading = false;
        });
        return;
      }
      if (raw == null) {
        code.text = widget.exercise.starter;
      } else {
        final data = jsonDecode(raw) as Map;
        final text = data['code'] as String;
        if (text.length > 16000) throw const FormatException();
        code.text = text;
        pendingId = data['pending_id'] as String?;
        if (pendingId != null &&
            !RegExp(
              r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}$',
            ).hasMatch(pendingId!)) {
          throw const FormatException();
        }
        if (data['grade'] != null) {
          final saved = GradeResult.fromJson(
            Map<String, dynamic>.from(data['grade']),
          );
          if (saved.exercise == widget.exercise.id) grade = saved;
        }
      }
      restored = true;
    } catch (_) {
      loadFailed = true;
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> persist() {
    if (!restored) return Future.value();
    final key = draftKey;
    final snapshot = jsonEncode({
      'code': code.text,
      'pending_id': pendingId,
      'grade': grade?.toJson(),
    });
    writes = writes
        .catchError((Object _) {})
        .then((_) => secureStorage.write(key: key, value: snapshot));
    return writes;
  }

  void changed(String _) {
    setState(() {
      output = null;
      grade = null;
      notice = null;
    });
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () async {
      try {
        await persist();
      } catch (_) {
        if (mounted) {
          setState(() => error = AppLocalizations.of(context)!.storageError);
        }
      }
    });
  }

  bool authorized() {
    final l = AppLocalizations.of(context)!;
    if (widget.account == null) {
      setState(() => error = l.signInRequired);
      return false;
    }
    if (CloudService.user?.id != widget.account) {
      setState(() => changedAccount = true);
      return false;
    }
    return true;
  }

  Future<void> runExample() async {
    if (!authorized() || busy) return;
    final l = AppLocalizations.of(context)!;
    setState(() {
      busy = true;
      error = null;
      output = null;
    });
    final submittedCode = code.text;
    final stdin = widget.exercise.examples[sample].stdin;
    try {
      await persist();
      final response = await CloudService.request(
        'POST',
        '/api/v1/code/run',
        expectedUser: widget.account!,
        body: {'code': submittedCode, 'stdin': stdin},
      );
      if (mounted && !changedAccount) {
        setState(() => output = Map<String, dynamic>.from(response as Map));
      }
    } catch (e) {
      if (mounted) setState(() => error = practiceError(e, l));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> submit({bool checkOnly = false}) async {
    if (!authorized() || busy) return;
    final l = AppLocalizations.of(context)!;
    if (checkOnly && pendingId == null) return;
    if (!checkOnly && pendingId != null) {
      setState(() => error = l.pendingAttempt);
      return;
    }
    setState(() {
      busy = true;
      error = null;
      grade = null;
    });
    try {
      if (!checkOnly) pendingId = submissionId();
      // Persist receipt before any execution request. Timeout/reconnect retains
      // this ID; checking it never automatically creates another paid attempt.
      await persist();
      final id = pendingId!;
      final response = await CloudService.request(
        checkOnly ? 'GET' : 'POST',
        checkOnly
            ? '/api/v1/practice/attempts/$id'
            : '/api/v1/practice/${widget.exercise.id}/submit',
        expectedUser: widget.account!,
        timeout: const Duration(seconds: 60),
        body: checkOnly ? null : {'submission_id': id, 'code': code.text},
      );
      if (!mounted || changedAccount) return;
      final result = GradeResult.fromJson(
        Map<String, dynamic>.from(response as Map),
      );
      if (result.id != id || result.exercise != widget.exercise.id) {
        throw const FormatException();
      }
      grade = result;
      if (result.state != 'pending') pendingId = null;
      await persist();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => error = practiceError(e, l));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> abandonPending() async {
    final l = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.newAttempt),
        content: Text(l.newAttemptWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l.confirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() {
        pendingId = null;
        grade = null;
      });
      try {
        await persist();
      } catch (_) {
        if (mounted) setState(() => error = l.storageError);
      }
    }
  }

  @override
  void dispose() {
    debounce?.cancel();
    if (restored) unawaited(persist().catchError((Object _) {}));
    authSubscription?.cancel();
    code.dispose();
    super.dispose();
  }

  String practiceError(Object error, AppLocalizations l) {
    if (error is ApiException) {
      if (error.status == 404) return l.attemptNotFound;
      if (error.status == 409) return l.pendingAttempt;
      if (error.status == 502 || error.status == 504) return l.gradeService;
    }
    return errorMessage(error, l);
  }

  String feedback(AppLocalizations l, String value) => switch (value) {
    'passed' => l.gradePassed,
    'wrong_answer' => l.gradeWrong,
    'runtime_error' => l.gradeRuntime,
    'timeout' => l.gradeTimeout,
    'output_limit' => l.gradeOutput,
    'service_unavailable' => l.gradeService,
    _ => l.pendingAttempt,
  };
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final e = widget.exercise;
    return Scaffold(
      appBar: AppBar(title: Text(e.title.inLanguage(english))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadFailed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l.storageError),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        loading = true;
                        loadFailed = false;
                      });
                      load();
                    },
                    child: Text(l.retry),
                  ),
                ],
              ),
            )
          : changedAccount
          ? Center(child: Text(l.sessionExpired))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  e.statement.inLanguage(english),
                  style: const TextStyle(height: 1.7),
                ),
                const SizedBox(height: 16),
                Text(
                  l.publicExamples,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                for (var i = 0; i < e.examples.length; i++)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l.stdin}: ${jsonEncode(e.examples[i].stdin)}',
                          ),
                          Text('${l.expectedOutput}: ${e.examples[i].stdout}'),
                          TextButton(
                            onPressed: busy
                                ? null
                                : () => setState(() {
                                    sample = i;
                                    output = null;
                                  }),
                            child: Text(
                              '${l.selectExample} ${i + 1}${sample == i ? " ✓" : ""}',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ExpansionTile(
                  title: Text(l.hints),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(e.hint.inLanguage(english)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                PythonEditor(
                  controller: code,
                  onChanged: changed,
                  enabled: !busy,
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: busy ? null : runExample,
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l.runExample),
                    ),
                    TextButton.icon(
                      onPressed: busy
                          ? null
                          : () async {
                              try {
                                await persist();
                                if (mounted) {
                                  setState(() => notice = l.draftSaved);
                                }
                              } catch (_) {
                                if (mounted) {
                                  setState(() => error = l.storageError);
                                }
                              }
                            },
                      icon: const Icon(Icons.save_outlined),
                      label: Text(l.save),
                    ),
                    TextButton(
                      onPressed: busy ? null : () => widget.onTutor(code.text),
                      child: Text(l.explain),
                    ),
                  ],
                ),
                if (output != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${l.output}: ${output!['status']}'),
                          SelectableText(output!['stdout'] as String),
                          if ((output!['stderr'] as String).isNotEmpty) ...[
                            Text(l.errors),
                            SelectableText(output!['stderr'] as String),
                            Text(l.pythonHint),
                          ],
                          if ((output!['compile_output'] as String).isNotEmpty)
                            SelectableText(output!['compile_output'] as String),
                          if (output!['truncated'] == true)
                            Text(l.outputTruncated),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(l.assessmentNotice),
                const SizedBox(height: 8),
                if (pendingId == null)
                  FilledButton.icon(
                    onPressed: busy ? null : submit,
                    icon: const Icon(Icons.fact_check_outlined),
                    label: Text(l.submitAssessment),
                  )
                else
                  Wrap(
                    spacing: 8,
                    children: [
                      FilledButton(
                        onPressed: busy ? null : () => submit(checkOnly: true),
                        child: Text(l.checkResult),
                      ),
                      TextButton(
                        onPressed: busy ? null : abandonPending,
                        child: Text(l.newAttempt),
                      ),
                    ],
                  ),
                if (grade != null)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      '${grade!.passed} / ${grade!.total}\n${feedback(l, grade!.feedback)}',
                    ),
                  ),
                if (busy) ...[const LinearProgressIndicator(), Text(l.running)],
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(error!),
                  ),
                if (notice != null) Text(notice!),
                ExpansionTile(
                  title: Text(l.sampleSolution),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SelectableText(
                        e.solution,
                        style: const TextStyle(fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
