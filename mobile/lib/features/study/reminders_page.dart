import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthState;

import '../../cloud_service.dart';
import 'reminder_preferences.dart';

class RemindersPage extends StatefulWidget {
  const RemindersPage({
    super.key,
    required this.account,
    required this.english,
    this.platform,
  });

  final String? account;
  final bool english;
  final ReminderPlatform? platform;

  @override
  State<RemindersPage> createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  late final ReminderPlatform platform = widget.platform ?? ReminderPlatform();
  ReminderPreferences preferences = const ReminderPreferences();
  StreamSubscription<AuthState>? authSubscription;
  String? status;
  bool loading = true;
  bool saving = false;

  String tr(String my, String en) => widget.english ? en : my;

  @override
  void initState() {
    super.initState();
    if (CloudService.configured) {
      authSubscription = CloudService.authChanges.listen((state) {
        if (state.session?.user.id != widget.account) {
          unawaited(platform.cancel());
          if (mounted) {
            setState(() {
              preferences = preferences.copyWith(enabled: false);
              status = tr(
                'Account ပြောင်းသွားသဖြင့် ယခင် reminder schedule ကို ပယ်ဖျက်လိုက်သည်။',
                'The previous reminder schedule was cancelled after the account changed.',
              );
            });
          }
        }
      });
    }
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loaded = ReminderPreferencesStore(prefs).read(widget.account);
      if (loaded.enabled) {
        final granted = await platform.requestPermission();
        if (granted) {
          await platform.schedule(loaded, english: widget.english);
        } else {
          status = tr(
            'Notification permission မရှိသေးပါ။ ခွင့်ပြုပါက schedule လုပ်နိုင်မည်။',
            'Notification permission is not available; allow it to schedule reminders.',
          );
        }
      }
      preferences = loaded;
    } catch (_) {
      status = tr(
        'Reminder ကို ဖတ်မရပါ။ Device notification settings ကို စစ်ပါ။',
        'Could not load reminders. Check device notification settings.',
      );
    }
    if (mounted) setState(() => loading = false);
  }

  Future<void> _save() async {
    if (saving) return;
    if (preferences.enabled && preferences.weekdays.isEmpty) {
      setState(() => status = tr('အနည်းဆုံး weekday တစ်ရက် ရွေးပါ။', 'Choose at least one weekday.'));
      return;
    }
    setState(() {
      saving = true;
      status = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await ReminderPreferencesStore(prefs).write(widget.account, preferences);
      if (!preferences.enabled) {
        await platform.cancel();
        status = tr('Reminder ကို ပိတ်ပြီး schedule ဟောင်းများကို ပယ်ဖျက်လိုက်သည်။', 'Reminders are off and scheduled alarms were cancelled.');
      } else {
        final granted = await platform.requestPermission();
        if (!granted) {
          await platform.cancel();
          status = tr(
            'Notification permission မပေးထားပါ။ Device Settings မှ permission ဖွင့်ပြီး Save ကို ထပ်နှိပ်ပါ။',
            'Notification permission was denied. Enable it in device Settings, then press Save again.',
          );
        } else {
          await platform.schedule(preferences, english: widget.english);
          status = tr(
            'Reminder schedule ကို သိမ်းပြီးပါပြီ။ အချိန်သည် device ၏ လက်ရှိ timezone ကို လိုက်နာမည်။',
            'Reminder schedule saved in the device time zone.',
          );
        }
      }
    } catch (_) {
      status = tr(
        'Reminder ကို စီစဉ်မရပါ။ Android notification settings ကို စစ်ပါ။',
        'Could not schedule reminders. Check Android notification settings.',
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: preferences.hour, minute: preferences.minute),
    );
    if (picked != null && mounted) {
      setState(() => preferences = preferences.copyWith(hour: picked.hour, minute: picked.minute));
    }
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labels = widget.english
        ? const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : const ['တနင်္လာ', 'အင်္ဂါ', 'ဗုဒ္ဓဟူး', 'ကြာသပတေး', 'သောကြာ', 'စနေ', 'တနင်္ဂနွေ'];
    final selectedTime = TimeOfDay(hour: preferences.hour, minute: preferences.minute);
    return Scaffold(
      appBar: AppBar(title: Text(tr('နေ့စဉ် Reminder', 'Daily reminders'))),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  tr(
                    'Device ပေါ်တွင်သာ schedule လုပ်သည်။ Notification ခွင့်ပြုချက်ကို လေးစားပြီး account ပြောင်းလျှင် လက်ရှိ schedule ကို ပယ်ဖျက်သည်။',
                    'Schedules are local to this device. Notification permission is respected, and changing accounts cancels the active schedule.',
                  ),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr('နေ့စဉ် လေ့လာမှု reminder', 'Enable daily study reminders')),
                  value: preferences.enabled,
                  onChanged: saving ? null : (value) => setState(() => preferences = preferences.copyWith(enabled: value)),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.access_time),
                    title: Text(tr('သင်ယူချိန်', 'Study time')),
                    subtitle: Text(selectedTime.format(context)),
                    onTap: saving ? null : _pickTime,
                  ),
                ),
                const SizedBox(height: 12),
                Text(tr('နေ့ရက်များ', 'Weekdays'), style: Theme.of(context).textTheme.titleMedium),
                Wrap(
                  spacing: 6,
                  children: [
                    for (var index = 0; index < labels.length; index++)
                      FilterChip(
                        label: Text(labels[index]),
                        selected: preferences.weekdays.contains(index + 1),
                        onSelected: saving
                            ? null
                            : (selected) {
                                final days = [...preferences.weekdays];
                                selected ? days.add(index + 1) : days.remove(index + 1);
                                setState(() => preferences = preferences.copyWith(weekdays: days.toSet().toList()));
                              },
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: preferences.studyMinutes,
                  decoration: InputDecoration(labelText: tr('သင်ယူမည့်ကြာချိန်', 'Study goal duration')),
                  items: [15, 25, 45, 60]
                      .map((minutes) => DropdownMenuItem(value: minutes, child: Text('$minutes ${tr('မိနစ်', 'minutes')}')))
                      .toList(),
                  onChanged: saving ? null : (value) => setState(() => preferences = preferences.copyWith(studyMinutes: value)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tr('Review reminder', 'Review reminder')),
                  subtitle: Text(tr('သတ်မှတ်ချိန်ပြီး ၄၅ မိနစ်အကြာတွင် ပြန်လည်လေ့ကျင့်ရန် သတိပေးမည်။', 'Send a separate review prompt 45 minutes after the study reminder.')),
                  value: preferences.reviewEnabled,
                  onChanged: saving ? null : (value) => setState(() => preferences = preferences.copyWith(reviewEnabled: value)),
                ),
                if (status != null)
                  Card(child: Padding(padding: const EdgeInsets.all(14), child: Text(status!))),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: saving ? null : _save,
                  icon: saving
                      ? const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.save_outlined),
                  label: Text(tr('သိမ်းပြီး schedule လုပ်မယ်', 'Save and schedule')),
                ),
              ],
            ),
    );
  }
}
