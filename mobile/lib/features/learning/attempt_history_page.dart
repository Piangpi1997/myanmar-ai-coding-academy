import 'dart:async';
import 'package:flutter/material.dart';
import '../../cloud_service.dart';
import '../../core/messages.dart';
import '../../l10n/generated/app_localizations.dart';
import 'grade_result.dart';
import 'learning_catalog.dart';

class AttemptHistoryPage extends StatefulWidget {
  const AttemptHistoryPage({super.key, required this.account});
  final String account;
  @override
  State<AttemptHistoryPage> createState() => _AttemptHistoryPageState();
}

class _AttemptHistoryPageState extends State<AttemptHistoryPage> {
  List<GradeResult> records = [];
  LearningCatalog? catalog;
  bool loading = true;
  String? error;
  StreamSubscription? authSubscription;
  @override
  void initState() {
    super.initState();
    if (CloudService.configured) {
      authSubscription = CloudService.authChanges.listen((_) {
        if (mounted && CloudService.user?.id != widget.account) {
          setState(() {
            records = [];
            error = 'account';
            loading = false;
          });
        }
      });
    }
    load();
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    super.dispose();
  }

  String titleFor(GradeResult result, bool english) {
    final matching = catalog!.exercises.where((e) => e.id == result.exercise);
    return matching.isEmpty
        ? result.exercise
        : matching.first.title.inLanguage(english);
  }

  Future<void> load() async {
    if (CloudService.user?.id != widget.account) {
      if (mounted) {
        setState(() {
          loading = false;
          error = 'account';
          records = [];
        });
      }
      return;
    }
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final data = await LearningCatalog.load();
      final raw =
          await CloudService.request(
                'GET',
                '/api/v1/practice/attempts',
                expectedUser: widget.account,
              )
              as List;
      if (mounted) {
        setState(() {
          catalog = data;
          records = raw
              .map((r) => GradeResult.fromJson(Map<String, dynamic>.from(r)))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          records = [];
          final l = AppLocalizations.of(context)!;
          error = e is ApiException && (e.status == 502 || e.status == 504)
              ? l.gradeService
              : errorMessage(e, l);
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final current = CloudService.user?.id == widget.account;
    return Scaffold(
      appBar: AppBar(
        title: Text(l.assessmentHistory),
        actions: [
          IconButton(
            tooltip: l.sync,
            onPressed: loading ? null : load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: !current
          ? Center(child: Text(l.sessionExpired))
          : loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(error!),
                  ),
                  TextButton(onPressed: load, child: Text(l.retry)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(l.historyNotice),
                const SizedBox(height: 16),
                if (records.isEmpty) Text(l.noAttempts),
                for (final result in records)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            titleFor(result, english),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text('${result.passed} / ${result.total}'),
                          Text(
                            result.feedback == 'passed'
                                ? l.gradePassed
                                : result.state == 'pending'
                                ? l.pendingAttempt
                                : l.gradeNotPassed,
                          ),
                          SelectableText(
                            result.id,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
