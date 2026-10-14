import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../cloud_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'learning_catalog.dart';
import 'project_store.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({
    super.key,
    required this.project,
    required this.account,
    required this.onCode,
  });
  final ProjectGuide project;
  final String? account;
  final Future<void> Function(String) onCode;
  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final notes = TextEditingController();
  Set<String> completed = {};
  bool loading = true,
      changedAccount = false,
      loadFailed = false,
      restored = false;
  String? error;
  Future<void> writes = Future.value();
  Timer? debounce;
  StreamSubscription? authSubscription;
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
      final data = await ProjectStore.load(
        widget.account,
        widget.project.id,
        widget.project.steps.map((s) => s.id).toSet(),
      );
      if (!mounted) return;
      if (CloudService.user?.id != widget.account) {
        setState(() {
          changedAccount = true;
          loading = false;
        });
        return;
      }
      restored = true;
      completed = data.completed;
      notes.text = data.notes;
    } catch (_) {
      if (mounted) {
        error = 'storage';
        loadFailed = true;
      }
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> save() {
    if (!restored) return Future.value();
    final record = ProjectRecord(completed: {...completed}, notes: notes.text);
    // Capture the original account before queueing. A late write never adopts a
    // newly signed-in account or imports previous-account project history.
    final account = widget.account;
    final project = widget.project.id;
    writes = writes
        .catchError((Object _) {})
        .then((_) => ProjectStore.save(account, project, record));
    return writes.catchError((Object _) {
      if (mounted) setState(() => error = 'storage');
    });
  }

  void changeNotes(String _) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), save);
  }

  Future<void> toggle(String id, bool checked) async {
    if (CloudService.user?.id != widget.account) {
      setState(() => changedAccount = true);
      return;
    }
    final next = <String>{...completed};
    if (checked) {
      next.add(id);
    } else {
      next.remove(id);
    }
    setState(() {
      completed = next;
      error = null;
    });
    await save();
  }

  @override
  void dispose() {
    debounce?.cancel();
    if (restored) unawaited(save());
    authSubscription?.cancel();
    notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final p = widget.project;
    String text(LocalizedText value) => value.inLanguage(english);
    Widget section(String title, String value) => Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(height: 1.7)),
        ],
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(text(p.title))),
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
                  '${switch (p.level) {
                    'beginner' => l.beginnerLevel,
                    'intermediate' => l.intermediateLevel,
                    _ => l.advancedLevel,
                  }} • ${p.language.toUpperCase()}',
                ),
                section(l.objectives, text(p.objective)),
                section(l.projectRequirements, text(p.requirements)),
                section(l.projectArchitecture, text(p.architecture)),
                section(l.projectWorkflow, l.projectProgressNotice),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: completed.length / p.steps.length,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('${completed.length} / ${p.steps.length}'),
                ),
                for (final step in p.steps)
                  CheckboxListTile(
                    key: ValueKey('project.step.${step.id}'),
                    value: completed.contains(step.id),
                    title: Text(text(step.text)),
                    onChanged: (v) => toggle(step.id, v!),
                  ),
                section(l.starterCode, l.starterNotice),
                const SizedBox(height: 12),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      p.starter,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        height: 1.6,
                      ),
                    ),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: () =>
                          Clipboard.setData(ClipboardData(text: p.starter)),
                      icon: const Icon(Icons.copy),
                      label: Text(l.copy),
                    ),
                    if (p.language == 'python')
                      TextButton.icon(
                        onPressed: () => widget.onCode(p.starter),
                        icon: const Icon(Icons.code),
                        label: Text(l.insertCode),
                      ),
                  ],
                ),
                section(l.projectTests, text(p.testing)),
                section(l.projectTroubleshooting, text(p.troubleshooting)),
                section(l.projectCompletion, text(p.completion)),
                section(l.references, p.reference),
                const SizedBox(height: 20),
                TextField(
                  controller: notes,
                  minLines: 3,
                  maxLines: 6,
                  maxLength: 2000,
                  decoration: InputDecoration(labelText: l.projectNotes),
                  onChanged: changeNotes,
                ),
                FilledButton.icon(
                  onPressed: () async {
                    await save();
                    if (context.mounted && error == null) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text(l.draftSaved)));
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: Text(l.save),
                ),
                if (error != null) Text(l.storageError),
                const SizedBox(height: 24),
              ],
            ),
    );
  }
}
