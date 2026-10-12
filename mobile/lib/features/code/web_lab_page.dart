import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../cloud_service.dart';
import '../../core/secure_store.dart';
import '../../l10n/generated/app_localizations.dart';
import 'web_project.dart';

class WebLabPage extends StatefulWidget {
  const WebLabPage({super.key, required this.account});
  final String? account;
  @override
  State<WebLabPage> createState() => _WebLabPageState();
}

class _WebLabPageState extends State<WebLabPage> {
  final html = TextEditingController(),
      css = TextEditingController(),
      js = TextEditingController();
  int editor = 0, generation = 0;
  bool loading = true, restored = false, changedAccount = false, live = true;
  int viewport = 0;
  String? storageError, previewError;
  List<String> console = [];
  Timer? saveTimer, previewTimer;
  Future<void> writes = Future.value();
  MethodChannel? channel;
  StreamSubscription? auth;
  String get key => 'web.v1.${widget.account ?? 'guest'}';
  WebProject get project =>
      WebProject(html: html.text, css: css.text, javascript: js.text);
  String t(String my, String en) =>
      Localizations.localeOf(context).languageCode == 'en' ? en : my;

  @override
  void initState() {
    super.initState();
    if (CloudService.configured) {
      auth = CloudService.authChanges.listen((_) {
        if (mounted && CloudService.user?.id != widget.account) {
          previewTimer?.cancel();
          saveTimer?.cancel();
          channel?.setMethodCallHandler(null);
          channel = null;
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

  void apply(WebProject value) {
    html.text = value.html;
    css.text = value.css;
    js.text = value.javascript;
  }

  Future<void> load() async {
    try {
      final raw = await secureStorage.read(key: key);
      if (!mounted ||
          changedAccount ||
          CloudService.user?.id != widget.account) {
        return;
      }
      apply(raw == null ? WebProject.starter : WebProject.decode(raw));
      restored = true;
      storageError = null;
    } catch (_) {
      if (mounted) storageError = 'storage';
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> save({bool announce = false}) async {
    if (!restored || changedAccount) return;
    final capturedKey = key, raw = project.encode();
    writes = writes
        .catchError((Object _) {})
        .then((_) => secureStorage.write(key: capturedKey, value: raw));
    try {
      await writes;
      if (mounted && !changedAccount) {
        setState(() => storageError = null);
        if (announce) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.saved)),
          );
        }
      }
    } catch (_) {
      if (mounted) setState(() => storageError = 'storage');
    }
  }

  void edit(String _) {
    saveTimer?.cancel();
    saveTimer = Timer(const Duration(milliseconds: 700), save);
    if (live) {
      previewTimer?.cancel();
      previewTimer = Timer(const Duration(milliseconds: 600), refresh);
    }
  }

  Future<void> refresh() async {
    if (!mounted || changedAccount || channel == null || !restored) return;
    setState(() {
      console = [];
      previewError = null;
    });
    try {
      await channel!.invokeMethod<void>('load', {
        'html': project.previewDocument(),
      });
    } catch (_) {
      if (mounted) setState(() => previewError = 'preview');
    }
  }

  void created(int id) {
    if (!mounted || changedAccount) return;
    final current = MethodChannel('academy/web-preview/$id');
    channel = current;
    current.setMethodCallHandler((call) async {
      if (!mounted ||
          changedAccount ||
          channel != current ||
          call.method != 'event') {
        return;
      }
      final args = call.arguments;
      if (args is! Map || args['text'] is! String) return;
      if (args['kind'] == 'ready') return;
      final text = (args['text'] as String).substring(
        0,
        (args['text'] as String).length.clamp(0, 1000),
      );
      setState(() {
        if (console.length < 80) {
          console = [...console, '${args['kind']}: $text'];
        }
      });
    });
    refresh();
  }

  void resetPreview() {
    previewTimer?.cancel();
    channel?.setMethodCallHandler(null);
    channel = null;
    setState(() {
      generation++;
      console = [];
      previewError = null;
    });
  }

  Future<void> resetProject() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          t('နမူနာဖြင့် အစားထိုးမလား။', 'Replace your saved project?'),
        ),
        content: Text(
          t(
            'လက်ရှိ HTML၊ CSS၊ JavaScript ကို starter နမူနာဖြင့် အစားထိုးမည်။',
            'This replaces the current HTML, CSS and JavaScript with the starter template.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t('မလုပ်ပါ', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t('အစားထိုးရန်', 'Replace')),
          ),
        ],
      ),
    );
    if (yes != true || !mounted || changedAccount) return;
    apply(WebProject.starter);
    setState(() {});
    await save();
    resetPreview();
  }

  @override
  void dispose() {
    saveTimer?.cancel();
    previewTimer?.cancel();
    auth?.cancel();
    channel?.setMethodCallHandler(null);
    if (restored && !changedAccount) {
      final capturedKey = key, raw = project.encode();
      // Preserve the original account scope even if a queued write completes later.
      writes = writes
          .catchError((Object _) {})
          .then((_) => secureStorage.write(key: capturedKey, value: raw))
          .catchError((Object _) {});
    }
    html.dispose();
    css.dispose();
    js.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final android = !kIsWeb && defaultTargetPlatform == TargetPlatform.android;
    if (changedAccount) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l.sessionExpired)),
      );
    }
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Web Code Lab')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (!restored) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t(
                  'Project ကို မဖတ်နိုင်ပါ သို့မဟုတ် မသိမ်းနိုင်ပါ။ ပြန်စမ်းပါ။',
                  'Project storage is unavailable. Please retry.',
                ),
              ),
              TextButton(onPressed: load, child: Text(l.retry)),
            ],
          ),
        ),
      );
    }
    final controller = [html, css, js][editor];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Code Lab'),
        actions: [
          IconButton(
            onPressed: () => save(announce: true),
            tooltip: l.save,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            t(
              'HTML / CSS / JavaScript ကို offline preview ဖြင့် လေ့ကျင့်ပါ။ Network၊ ဖိုင်၊ popup နှင့် phone API များ မသုံးနိုင်ပါ။',
              'Practice HTML, CSS and JavaScript in an offline preview. Network, file access, popups and phone APIs are blocked.',
            ),
          ),
          const SizedBox(height: 12),
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('HTML')),
              ButtonSegment(value: 1, label: Text('CSS')),
              ButtonSegment(value: 2, label: Text('JavaScript')),
            ],
            selected: {editor},
            onSelectionChanged: (value) =>
                setState(() => editor = value.single),
          ),
          const SizedBox(height: 12),
          TextField(
            key: ValueKey(editor),
            controller: controller,
            maxLines: 10,
            minLines: 10,
            maxLength: 16000,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.multiline,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            onChanged: edit,
            decoration: InputDecoration(
              labelText: ['HTML', 'CSS', 'JavaScript'][editor],
              alignLabelWithHint: true,
            ),
          ),
          if (storageError != null)
            Text(
              t(
                'Project ကို မဖတ်နိုင်ပါ သို့မဟုတ် မသိမ်းနိုင်ပါ။ ပြန်စမ်းပါ။',
                'Project storage is unavailable. Please retry.',
              ),
            ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: Text(t('အလိုအလျောက် preview', 'Live preview')),
                selected: live,
                onSelected: (value) {
                  setState(() => live = value);
                  if (value) {
                    refresh();
                  } else {
                    previewTimer?.cancel();
                  }
                },
              ),
              OutlinedButton.icon(
                onPressed: refresh,
                icon: const Icon(Icons.refresh),
                label: Text(t('ပြန်ပြရန်', 'Refresh')),
              ),
              OutlinedButton(
                onPressed: resetPreview,
                child: Text(t('Preview ပြန်စရန်', 'Reset preview')),
              ),
              TextButton(
                onPressed: resetProject,
                child: Text(t('Starter နမူနာ', 'Starter template')),
              ),
            ],
          ),
          DropdownButtonFormField<int>(
            initialValue: viewport,
            decoration: InputDecoration(
              labelText: t('Preview အကျယ်', 'Viewport width'),
            ),
            items: [0, 320, 390, 768]
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(
                      value == 0
                          ? t('Screen အကျယ်', 'Fit screen')
                          : '$value px',
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => viewport = value ?? 0),
          ),
          const SizedBox(height: 12),
          if (!android)
            Text(
              t(
                'တကယ့် preview ကို Android app တွင် ဖွင့်ပါ။',
                'Open the Android app for the native preview.',
              ),
            )
          else
            SizedBox(
              height: 340,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = viewport == 0
                      ? constraints.maxWidth
                      : viewport.toDouble();
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      height: 340,
                      child: AndroidView(
                        key: ValueKey(generation),
                        viewType: 'academy/restricted-web-preview',
                        layoutDirection: TextDirection.ltr,
                        onPlatformViewCreated: created,
                        creationParamsCodec: const StandardMessageCodec(),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (previewError != null)
            Text(
              t(
                'Preview မဖွင့်နိုင်ပါ။ Reset preview ဖြင့် ပြန်စမ်းပါ။',
                'Preview could not load. Try Reset preview.',
              ),
            ),
          const SizedBox(height: 12),
          Text(
            t('Console နှင့် errors', 'Console and errors'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (console.isEmpty)
            Text(t('Console message မရှိသေးပါ။', 'No console messages.')),
          for (final message in console)
            SelectableText(
              message,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
        ],
      ),
    );
  }
}
