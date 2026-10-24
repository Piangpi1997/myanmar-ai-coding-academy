import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../cloud_service.dart';
import 'study_store.dart';
import 'study_tracker.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key, required this.account, required this.english});
  final String? account;
  final bool english;

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with WidgetsBindingObserver {
  final StudyTracker tracker = StudyTracker();
  StudyStore? store;
  List<StudySession> sessions = [];
  StreamSubscription<AuthState>? authSubscription;
  Timer? ticker;
  String activity = 'lesson';
  String? status;
  bool loading = true;
  bool syncFailed = false;

  String tr(String my, String en) => widget.english ? en : my;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (CloudService.configured) {
      authSubscription = CloudService.authChanges.listen((state) {
        if (state.session?.user.id != widget.account) {
          unawaited(_stopTimer(notify: true));
        }
      });
    }
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      store = StudyStore(
        prefs,
        loadRemote: CloudService.loadStudySessions,
        saveRemote: CloudService.saveStudySession,
      );
      sessions = store!.read(widget.account);
      if (widget.account != null && CloudService.apiConfigured) {
        final result = await store!.sync(widget.account!);
        sessions = result.sessions;
        syncFailed = result.hadError;
        if (result.hadError) {
          status = tr(
            'Cloud history ကို sync မလုပ်နိုင်သေးပါ။ Local မှတ်တမ်းကို ထိန်းထားပြီး ပြန်စမ်းနိုင်သည်။',
            'Cloud history is not synced yet. Local checkpoints are preserved for retry.',
          );
        }
      }
    } catch (_) {
      status = tr(
        'လေ့လာချိန်မှတ်တမ်းကို ဖတ်မရပါ။ မူရင်းအချက်အလက်ကို မဖျက်ထားပါ။',
        'Study history could not be read; the stored data was left untouched.',
      );
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _record(StudySession? session) async {
    if (session == null || store == null) return;
    try {
      sessions = await store!.append(widget.account, session);
      if (widget.account != null && CloudService.apiConfigured) {
        final result = await store!.sync(widget.account!);
        sessions = result.sessions;
        syncFailed = result.hadError;
        status = result.hadError
            ? tr(
                'Cloud sync မအောင်မြင်ပါ။ မှတ်တမ်းကို device ပေါ်တွင် သိမ်းထားပြီး ပြန်စမ်းနိုင်သည်။',
                'Cloud sync failed. The checkpoint is saved on this device and can be retried.',
              )
            : null;
      } else {
        status = widget.account == null
            ? tr(
                'Guest မှတ်တမ်းကို ဤ device ပေါ်တွင်သာ သိမ်းထားသည်။',
                'Guest history is stored only on this device.',
              )
            : tr(
                'Backend မချိတ်ဆက်ရသေးပါ။ မှတ်တမ်းကို device ပေါ်တွင် သိမ်းထားသည်။',
                'The backend is not configured; this history remains on this device.',
              );
      }
      if (mounted) setState(() {});
    } catch (_) {
      syncFailed = widget.account != null;
      status = tr(
        'မှတ်တမ်းကို device ပေါ်တွင် သိမ်းမရပါ။ နေရာလွတ်နှင့် app storage ကို စစ်ပါ။',
        'Could not save this checkpoint on the device. Check available storage.',
      );
      if (mounted) setState(() {});
    }
  }

  void _start() {
    if (store == null || loading) return;
    tracker.start(activity: activity);
    ticker?.cancel();
    ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !tracker.isRunning) return;
      if (tracker.currentSegmentSeconds >= 60) {
        unawaited(_record(tracker.checkpoint()));
      }
      setState(() {});
    });
    setState(() => status = null);
  }

  Future<void> _stopTimer({bool notify = false}) async {
    ticker?.cancel();
    ticker = null;
    final last = tracker.stop();
    await _record(last);
    if (notify && mounted) {
      setState(() {
        status = tr(
          'App နောက်ခံသို့ ဝင်သွားသဖြင့် timer ကို pause လုပ်ထားသည်။ ပြန်စရန် Start ကိုနှိပ်ပါ။',
          'The timer was paused when the app left the foreground. Press Start to resume.',
        );
      });
    }
    if (mounted) setState(() {});
  }

  Future<void> _stopManually() => _stopTimer();

  Future<void> _retrySync() async {
    if (widget.account == null || store == null || !CloudService.apiConfigured) return;
    final result = await store!.sync(widget.account!);
    if (!mounted) return;
    setState(() {
      sessions = result.sessions;
      syncFailed = result.hadError;
      status = result.hadError
          ? tr('ပြန်လည် sync မအောင်မြင်ပါ။', 'Sync retry failed.')
          : tr('မှတ်တမ်း sync ပြီးပါပြီ။', 'Study history is synced.');
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(_stopTimer(notify: false));
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    authSubscription?.cancel();
    ticker?.cancel();
    if (tracker.isRunning) unawaited(_record(tracker.stop()));
    super.dispose();
  }

  String _duration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final remainder = seconds % 60;
    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${remainder}s';
    return '${remainder}s';
  }

  List<int> _weekTotals() {
    final today = DateTime.now();
    final monday = DateTime(today.year, today.month, today.day)
        .subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (index) {
      final day = monday.add(Duration(days: index));
      return sessions
          .where((session) {
            final started = session.startedAt.toLocal();
            return started.year == day.year &&
                started.month == day.month &&
                started.day == day.day;
          })
          .fold<int>(0, (total, session) => total + session.durationSeconds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final week = _weekTotals();
    final totalWeekSeconds = week.fold<int>(0, (sum, item) => sum + item);
    final labels = widget.english
        ? const ['M', 'T', 'W', 'T', 'F', 'S', 'S']
        : const ['တ', 'အ', 'ဗ', 'ကြ', 'သော', 'စ', 'တ'];
    final running = tracker.isRunning;
    return Scaffold(
      appBar: AppBar(title: Text(tr('လေ့လာချိန်', 'Study timer'))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          _duration(tracker.elapsedSeconds),
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          tr(
                            'Timer သည် app ကို foreground တွင်ဖွင့်ထားသည့်အချိန်ကိုသာ မှတ်တမ်းတင်သည်။',
                            'The timer records only time while this app is in the foreground.',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: activity,
                          decoration: InputDecoration(
                            labelText: tr('လေ့လာမှုအမျိုးအစား', 'Study activity'),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'lesson',
                              child: Text(tr('သင်ခန်းစာ', 'Lesson')),
                            ),
                            DropdownMenuItem(
                              value: 'coding',
                              child: Text(tr('Code ရေးခြင်း', 'Coding')),
                            ),
                            DropdownMenuItem(
                              value: 'review',
                              child: Text(tr('ပြန်လည်လေ့ကျင့်ခြင်း', 'Review')),
                            ),
                          ],
                          onChanged: running
                              ? null
                              : (value) => setState(() => activity = value ?? 'lesson'),
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: store == null
                              ? null
                              : running
                              ? _stopManually
                              : _start,
                          icon: Icon(running ? Icons.pause : Icons.play_arrow),
                          label: Text(
                            running
                                ? tr('Pause နှင့် သိမ်းရန်', 'Pause and save')
                                : tr('စတင်လေ့လာမယ်', 'Start studying'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (status != null)
                  Card(
                    child: ListTile(
                      leading: Icon(syncFailed ? Icons.sync_problem : Icons.info_outline),
                      title: Text(status!),
                      trailing: syncFailed && widget.account != null
                          ? IconButton(
                              tooltip: tr('ပြန်စမ်းရန်', 'Retry sync'),
                              onPressed: _retrySync,
                              icon: const Icon(Icons.refresh),
                            )
                          : null,
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  tr('ယခုအပတ်', 'This week'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_duration(totalWeekSeconds)} · ${sessions.length} ${tr('မှတ်တမ်း', 'checkpoints')}'),
                        const SizedBox(height: 14),
                        for (var index = 0; index < week.length; index++)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                SizedBox(width: 36, child: Text(labels[index])),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: (week[index] / 3600)
                                        .clamp(0.0, 1.0)
                                        .toDouble(),
                                    minHeight: 8,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                SizedBox(width: 48, child: Text('${week[index] ~/ 60}m')),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  tr('လတ်တလောမှတ်တမ်း', 'Recent study history'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (sessions.isEmpty)
                  Card(
                    child: ListTile(
                      title: Text(tr('မှတ်တမ်းမရှိသေးပါ။ Timer ကိုစတင်ပါ။', 'No study sessions yet. Start the timer to create one.')),
                    ),
                  ),
                for (final session in sessions.take(30))
                  Card(
                    child: ListTile(
                      leading: Icon(
                        session.activity == 'coding'
                            ? Icons.code
                            : session.activity == 'review'
                            ? Icons.replay
                            : Icons.menu_book_outlined,
                      ),
                      title: Text('${_duration(session.durationSeconds)} · ${_activityName(session.activity)}'),
                      subtitle: Text(
                        '${session.startedAt.toLocal()} · ${session.synced ? tr('Cloud သိမ်းပြီး', 'Synced') : tr('Device မှတ်တမ်း', 'Device checkpoint')}',
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  String _activityName(String value) => switch (value) {
    'coding' => tr('Code ရေးခြင်း', 'Coding'),
    'review' => tr('ပြန်လည်လေ့ကျင့်ခြင်း', 'Review'),
    _ => tr('သင်ခန်းစာ', 'Lesson'),
  };
}
