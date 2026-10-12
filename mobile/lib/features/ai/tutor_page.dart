import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../../cloud_service.dart';
import '../../core/messages.dart';
import '../../core/secure_store.dart';
import '../../l10n/generated/app_localizations.dart';
import 'byok_store.dart';
import 'provider_page.dart';
import 'direct_tutor_client.dart';

class TutorPage extends StatefulWidget {
  const TutorPage({
    super.key,
    required this.account,
    required this.onCode,
    this.lessonContext = '',
    this.codeContext = '',
    this.request = sendTutorRequest,
  });
  final String? account;
  final Future<Map<String, dynamic>> Function(
    ByokConfig,
    Map<String, dynamic>,
    String?,
  )
  request;
  final String lessonContext;
  final String codeContext;
  final void Function(String) onCode;
  @override
  State<TutorPage> createState() => _TutorPageState();
}

class _TutorPageState extends State<TutorPage> {
  final question = TextEditingController();
  final scroll = ScrollController();
  List<Map<String, String>> messages = [];
  String mode = 'ask';
  bool loading = true;
  bool sending = false;
  String? error;
  bool retryable = false;
  int revision = 0;
  Future<void> writes = Future.value();
  String get scope => widget.account ?? 'guest';
  String get historyKey => 'chat.v1.$scope';
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void didUpdateWidget(covariant TutorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!sending &&
        widget.codeContext.isNotEmpty &&
        widget.codeContext != oldWidget.codeContext) {
      mode = 'explain';
      if (question.text.trim().isEmpty) {
        question.text = AppLocalizations.of(context)!.explainPrompt;
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.codeContext.isNotEmpty &&
        question.text.isEmpty &&
        messages.isEmpty) {
      mode = 'explain';
      question.text = AppLocalizations.of(context)!.explainPrompt;
    }
  }

  Future<void> load() async {
    try {
      {
        final raw = await secureStorage.read(key: historyKey);
        if (mounted && raw != null) {
          messages = (jsonDecode(raw) as List)
              .map((e) => Map<String, String>.from(e as Map))
              .toList();
        }
      }
    } catch (_) {
      /* An unreadable local history does not expose or fabricate messages. */
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> persist() {
    final key = historyKey;
    final snapshot = jsonEncode(
      messages.length > 40 ? messages.sublist(messages.length - 40) : messages,
    );
    writes = writes
        .catchError((Object _) {})
        .then((_) => secureStorage.write(key: key, value: snapshot));
    return writes;
  }

  List<Map<String, String>> contextMessages() {
    final selected = <Map<String, String>>[];
    var size =
        widget.lessonContext.length.clamp(0, 2000) +
        widget.codeContext.length.clamp(0, 12000);
    for (final item in messages.reversed) {
      final value = item['content']!;
      final clipped = value.length > 4000 ? value.substring(0, 4000) : value;
      if (selected.length >= 12 || size + clipped.length > 22000) break;
      selected.insert(0, {'role': item['role']!, 'content': clipped});
      size += clipped.length;
    }
    return selected;
  }

  Future<void> send({bool retry = false}) async {
    final l = AppLocalizations.of(context)!;
    final account = widget.account;
    if (CloudService.user?.id != account) {
      setState(() => error = l.sessionExpired);
      return;
    }
    if (!retry && question.text.trim().isEmpty) return;
    if (sending || loading) return;
    final currentRevision = revision;
    setState(() {
      sending = true;
      error = null;
      retryable = false;
    });
    try {
      final config = await ByokStore.read(scope);
      if (!mounted || revision != currentRevision) return;
      if (config == null) {
        setState(() => error = l.byokRequired);
        return;
      }
      if (!retry) {
        messages.add({'role': 'user', 'content': question.text.trim()});
        question.clear();
        await persist();
      }
      if (!mounted || revision != currentRevision) return;
      final response = await widget.request(config, {
        'provider': config.provider,
        'model': config.model,
        'mode': mode,
        'language': Localizations.localeOf(context).languageCode,
        'lesson_context': widget.lessonContext.length > 2000
            ? widget.lessonContext.substring(0, 2000)
            : widget.lessonContext,
        'code': widget.codeContext.length > 12000
            ? widget.codeContext.substring(0, 12000)
            : widget.codeContext,
        'messages': contextMessages(),
        'max_tokens': 1024,
      }, account);
      if (!mounted || revision != currentRevision) return;
      messages.add({
        'role': 'assistant',
        'content': response['content'] as String,
      });
      await persist();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted && revision == currentRevision) {
        setState(() {
          error = errorMessage(e, l);
          retryable = messages.isNotEmpty && messages.last['role'] == 'user';
        });
      }
    } finally {
      if (mounted && revision == currentRevision) {
        setState(() => sending = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && scroll.hasClients) {
            scroll.animateTo(
              scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
            );
          }
        });
      }
    }
  }

  Future<void> clear() async {
    final l = AppLocalizations.of(context)!;
    final approved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.clearChat),
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
    revision++;
    setState(() {
      messages.clear();
      error = null;
      retryable = false;
      sending = false;
    });
    try {
      await persist();
    } catch (_) {
      if (mounted) setState(() => error = l.storageError);
    }
  }

  @override
  void dispose() {
    question.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final modes = {
      'ask': l.ask,
      'explain': l.explain,
      'debug': l.debug,
      'practice': l.practice,
      'review': l.review,
      'mentor': l.mentor,
      'project': l.project,
    };
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 380;
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: mode,
                      isExpanded: true,
                      items: modes.entries
                          .map(
                            (e) => DropdownMenuItem(
                              value: e.key,
                              child: Text(e.value),
                            ),
                          )
                          .toList(),
                      onChanged: sending
                          ? null
                          : (v) => setState(() => mode = v!),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: sending
                        ? null
                        : () => Navigator.push(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ProviderPage(account: widget.account),
                            ),
                          ),
                    icon: const Icon(Icons.tune),
                    label: Text(l.provider),
                  ),
                  IconButton(
                    tooltip: l.clearChat,
                    onPressed: sending || loading ? null : clear,
                    icon: const Icon(Icons.delete_outline),
                  ),
                ],
              ),
            ),
            if (!compact)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  l.aiDisclaimer,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (!compact &&
                (widget.lessonContext.isNotEmpty ||
                    widget.codeContext.isNotEmpty))
              Chip(label: Text(l.lessonContext)),

            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: scroll,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.isEmpty ? 1 : messages.length,
                      itemBuilder: (context, index) {
                        if (messages.isEmpty) {
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(l.tutorWelcome),
                            ),
                          );
                        }
                        final item = messages[index];
                        final content = item['content']!;
                        final blocks = RegExp(
                          r'```(?:python|py)?\s*\n([\s\S]*?)```',
                        ).allMatches(content).toList();
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['role'] == 'user'
                                      ? l.question
                                      : 'AI Tutor',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                MarkdownBody(
                                  data: content,
                                  selectable: true,
                                  sizedImageBuilder: (config) =>
                                      Text(config.alt ?? '[Image]'),
                                ),
                                Wrap(
                                  spacing: 8,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => Clipboard.setData(
                                        ClipboardData(text: content),
                                      ),
                                      icon: const Icon(Icons.copy, size: 16),
                                      label: Text(l.copy),
                                    ),
                                    for (final block in blocks)
                                      TextButton.icon(
                                        onPressed: () =>
                                            widget.onCode(block.group(1)!),
                                        icon: const Icon(Icons.code, size: 16),
                                        label: Text(l.insertCode),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (sending) const LinearProgressIndicator(),
            if (error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(child: Text(error!)),
                    if (retryable)
                      TextButton(
                        onPressed: sending ? null : () => send(retry: true),
                        child: Text(l.retry),
                      ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: question,
                      minLines: 1,
                      maxLines: compact ? 1 : 4,
                      maxLength: 4000,
                      enabled: !sending && !loading,
                      decoration: InputDecoration(
                        hintText: l.question,
                        counterText: '',
                      ),
                    ),
                  ),
                  IconButton.filled(
                    tooltip: l.send,
                    onPressed: sending || loading ? null : send,
                    icon: const Icon(Icons.arrow_upward),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
