import 'package:flutter/material.dart';
import '../../cloud_service.dart';
import '../../l10n/generated/app_localizations.dart';
import 'byok_store.dart';
import 'direct_tutor_client.dart';
import '../../core/messages.dart';

class ProviderPage extends StatefulWidget {
  const ProviderPage({super.key, required this.account});
  final String? account;
  @override
  State<ProviderPage> createState() => _ProviderPageState();
}

class _ProviderPageState extends State<ProviderPage> {
  final model = TextEditingController();
  final apiKey = TextEditingController();
  String provider = 'openrouter';
  String transport = 'direct';
  String get scope => widget.account ?? 'guest';
  ByokConfig? saved;
  bool consent = false;
  bool busy = true;
  bool loadFailed = false;
  String? message;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final config = await ByokStore.read(scope);
      if (!mounted) return;
      saved = config;
      if (config != null) {
        provider = config.provider;
        transport = config.transport;
        model.text = config.model;
        consent = true;
      }
    } catch (_) {
      loadFailed = true;
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> save() async {
    final l = AppLocalizations.of(context)!;
    final key = apiKey.text.trim().isNotEmpty
        ? apiKey.text.trim()
        : saved?.key ?? '';
    if (!consent ||
        key.length < 8 ||
        key.length > 512 ||
        !RegExp(r'^[\x21-\x7E]+$').hasMatch(key) ||
        !RegExp(r'^[a-zA-Z0-9_./:\-]{1,128}$').hasMatch(model.text.trim())) {
      setState(() => message = l.byokInvalid);
      return;
    }
    if (CloudService.user?.id != widget.account) {
      setState(() => message = l.sessionExpired);
      return;
    }
    setState(() => busy = true);
    try {
      final config = ByokConfig(
        provider: provider,
        model: model.text.trim(),
        key: key,
        transport: transport,
      );
      await ByokStore.save(scope, config);
      apiKey.clear();
      if (mounted) {
        setState(() {
          saved = config;
          message = l.saved;
        });
      }
    } catch (_) {
      if (mounted) setState(() => message = l.storageError);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> remove() async {
    final l = AppLocalizations.of(context)!;
    if (CloudService.user?.id != widget.account) {
      setState(() => message = l.sessionExpired);
      return;
    }
    setState(() => busy = true);
    try {
      await ByokStore.remove(scope);
      apiKey.clear();
      if (mounted) {
        setState(() {
          saved = null;
          consent = false;
          message = l.saved;
        });
      }
    } catch (_) {
      if (mounted) setState(() => message = l.storageError);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> loadModels() async {
    final l = AppLocalizations.of(context)!;
    final key = apiKey.text.trim().isNotEmpty
        ? apiKey.text.trim()
        : saved?.key ?? '';
    if (!consent || key.length < 8) {
      setState(() => message = l.byokInvalid);
      return;
    }
    if (CloudService.user?.id != widget.account) {
      setState(() => message = l.sessionExpired);
      return;
    }
    setState(() => busy = true);
    try {
      final ids = await DirectTutorClient.shared.models(
        ByokConfig(provider: provider, model: '', key: key),
      );
      if (!mounted || CloudService.user?.id != widget.account) return;
      if (ids.isEmpty) {
        setState(() => message = l.noModels);
        return;
      }
      var search = '';
      final selected = await showDialog<String>(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, update) {
            final visible = ids
                .where((id) => id.toLowerCase().contains(search.toLowerCase()))
                .toList();
            return AlertDialog(
              title: Text(l.model),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(hintText: l.searchModels),
                      onChanged: (v) => update(() => search = v),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: visible.length,
                        itemBuilder: (context, i) => ListTile(
                          title: Text(visible[i]),
                          onTap: () => Navigator.pop(context, visible[i]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l.cancel),
                ),
              ],
            );
          },
        ),
      );
      if (mounted && selected != null) setState(() => model.text = selected);
    } catch (e) {
      if (mounted) setState(() => message = errorMessage(e, l));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    model.dispose();
    apiKey.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.byokSettings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.key, size: 52, color: Color(0xFF00D9E8)),
          const SizedBox(height: 16),
          Text(transport == 'direct' ? l.directPrivacy : l.byokPrivacy),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(
            key: ValueKey('transport.$transport'),
            initialValue: transport,
            decoration: InputDecoration(labelText: l.aiConnection),
            items: [
              DropdownMenuItem(
                value: 'direct',
                child: Text(l.directConnection),
              ),
              if (widget.account != null && CloudService.apiConfigured)
                DropdownMenuItem(
                  value: 'backend',
                  child: Text(l.backendConnection),
                ),
              if (transport == 'backend' &&
                  !(widget.account != null && CloudService.apiConfigured))
                DropdownMenuItem(
                  value: 'backend',
                  child: Text(l.backendConnection),
                ),
            ],
            onChanged: busy
                ? null
                : (v) => setState(() {
                    transport = v!;
                    consent = false;
                  }),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey(provider),
            initialValue: provider,
            decoration: InputDecoration(labelText: l.provider),
            items: providers
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
            onChanged: busy
                ? null
                : (p) => setState(() {
                    provider = p!;
                    saved = null;
                    apiKey.clear();
                    model.clear();
                    consent = false;
                  }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: model,
            maxLength: 128,
            enabled: !busy,
            decoration: InputDecoration(labelText: l.model),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: apiKey,
            enabled: !busy,
            obscureText: true,
            autocorrect: false,
            enableSuggestions: false,
            enableIMEPersonalizedLearning: false,
            maxLength: 512,
            decoration: InputDecoration(
              labelText: l.apiKey,
              helperText: saved == null ? null : l.keySaved,
              helperMaxLines: 3,
            ),
          ),
          CheckboxListTile(
            value: consent,
            title: Text(
              transport == 'direct' ? l.directConsent : l.byokConsent,
            ),
            onChanged: busy ? null : (v) => setState(() => consent = v!),
          ),
          if (transport == 'direct')
            OutlinedButton.icon(
              onPressed: busy ? null : loadModels,
              icon: const Icon(Icons.cloud_download_outlined),
              label: Text(l.loadModels),
            ),
          if (loadFailed) Text(l.storageError),
          if (message != null)
            Padding(padding: const EdgeInsets.all(8), child: Text(message!)),
          FilledButton.icon(
            onPressed: busy ? null : save,
            icon: const Icon(Icons.save_outlined),
            label: Text(l.save),
          ),
          TextButton.icon(
            onPressed: busy ? null : remove,
            icon: const Icon(Icons.delete_outline),
            label: Text(l.removeKey),
          ),
        ],
      ),
    );
  }
}
