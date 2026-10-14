import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../cloud_service.dart';
import '../../core/messages.dart';
import '../../core/secure_store.dart';
import '../../l10n/generated/app_localizations.dart';
import 'python_controller.dart';
import 'python_editor.dart';
import 'web_lab_page.dart';

class CodeLabPage extends StatefulWidget {
  const CodeLabPage({
    super.key,
    this.account,
    this.initialCode,
    required this.onAsk,
  });
  final String? account;
  final String? initialCode;
  final void Function(String) onAsk;
  @override
  State<CodeLabPage> createState() => _CodeLabPageState();
}

class _CodeLabPageState extends State<CodeLabPage> {
  static const example = 'name = input("Your name: ")\nprint("Hello, " + name)';
  final code = PythonController();
  final stdin = TextEditingController(text: 'Myanmar');
  double fontSize = 15;
  bool loading = true;
  bool running = false;
  String? error;
  String? notice;
  Map<String, dynamic>? result;
  Timer? debounce;
  Future<void> writes = Future.value();
  String get draftKey => 'code.v1.${widget.account ?? 'guest'}';
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final raw = await secureStorage.read(key: draftKey);
      if (!mounted) return;
      if (raw != null) {
        final data = jsonDecode(raw) as Map;
        code.text = data['code'] as String;
        stdin.text = data['stdin'] as String;
      } else {
        code.text = example;
      }
    } catch (_) {
      if (mounted) code.text = example;
    }
    if (!mounted) return;
    if (widget.initialCode != null) code.text = widget.initialCode!;
    setState(() => loading = false);
  }

  Future<void> save({bool announce = false}) async {
    final key = draftKey;
    final snapshot = jsonEncode({'code': code.text, 'stdin': stdin.text});
    writes = writes
        .catchError((Object _) {})
        .then((_) => secureStorage.write(key: key, value: snapshot));
    try {
      await writes;
      if (announce && mounted) {
        setState(() => notice = AppLocalizations.of(context)!.draftSaved);
      }
    } catch (_) {
      if (mounted) {
        setState(() => error = AppLocalizations.of(context)!.storageError);
      }
    }
  }

  void changed(String _) {
    setState(() {
      result = null;
      notice = null;
    });
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), save);
  }

  Future<void> run() async {
    final l = AppLocalizations.of(context)!;
    if (widget.account == null) {
      setState(() => error = l.signInRequired);
      return;
    }
    setState(() {
      running = true;
      error = null;
      result = null;
    });
    try {
      await save();
      final data = await CloudService.request(
        'POST',
        '/api/v1/code/run',
        expectedUser: widget.account!,
        body: {'code': code.text, 'stdin': stdin.text},
      );
      if (mounted) {
        setState(() => result = Map<String, dynamic>.from(data as Map));
      }
    } catch (e) {
      if (mounted) setState(() => error = errorMessage(e, l));
    } finally {
      if (mounted) setState(() => running = false);
    }
  }

  Future<void> reset() async {
    final l = AppLocalizations.of(context)!;
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.replaceDraft),
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
    if (approved != true || !mounted) return;
    code.text = example;
    stdin.text = 'Myanmar';
    changed('');
  }

  @override
  void dispose() {
    debounce?.cancel();
    if (!loading) {
      unawaited(save());
    }
    code.dispose();
    stdin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (loading) return const Center(child: CircularProgressIndicator());
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Python Code Lab',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        OutlinedButton.icon(
          onPressed: running
              ? null
              : () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WebLabPage(account: widget.account),
                  ),
                ),
          icon: const Icon(Icons.web),
          label: Text(
            Localizations.localeOf(context).languageCode == 'en'
                ? 'HTML / CSS / JavaScript lab'
                : 'HTML / CSS / JavaScript လေ့ကျင့်ရန်',
          ),
        ),
        if (widget.account == null) Text(l.signInRequired),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.icon(
              onPressed: running ? null : run,
              icon: const Icon(Icons.play_arrow),
              label: Text(l.run),
            ),
            OutlinedButton(
              onPressed: () => save(announce: true),
              child: Text(l.save),
            ),
            TextButton(onPressed: running ? null : reset, child: Text(l.reset)),
            TextButton(
              onPressed: () => widget.onAsk(code.text),
              child: Text(l.explain),
            ),
          ],
        ),
        Row(
          children: [
            Text(l.fontSize),
            Expanded(
              child: Slider(
                value: fontSize,
                min: 12,
                max: 24,
                divisions: 12,
                label: fontSize.round().toString(),
                onChanged: (v) => setState(() => fontSize = v),
              ),
            ),
          ],
        ),
        PythonEditor(
          controller: code,
          onChanged: changed,
          fontSize: fontSize,
          enabled: !running,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: stdin,
          enabled: !running,
          maxLines: 3,
          maxLength: 4000,
          onChanged: changed,
          decoration: InputDecoration(labelText: l.stdin),
        ),
        if (notice != null) Text(notice!),
        if (running) ...[const LinearProgressIndicator(), Text(l.running)],
        if (error != null) Text(error!),
        const SizedBox(height: 16),
        Text(l.output, style: Theme.of(context).textTheme.titleMedium),
        if (result == null) Text(l.notRun),
        if (result != null) ...[
          Text('${result!['status']} (${result!['status_id']})'),
          SelectableText(
            result!['stdout'] as String,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
          if ((result!['stderr'] as String).isNotEmpty ||
              (result!['compile_output'] as String).isNotEmpty) ...[
            Text(l.errors),
            SelectableText(
              '${result!['stderr']}\n${result!['compile_output']}',
            ),
            Text(l.pythonHint),
          ],
          if (result!['truncated'] == true) Text(l.outputTruncated),
        ],
      ],
    );
  }
}
