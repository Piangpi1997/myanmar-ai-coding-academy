import 'dart:async';
import 'package:flutter/services.dart';
import 'core/academy_theme.dart';
import 'features/learning/academy_tracks.dart';
import 'features/learning/practice_test_page.dart';
import 'features/code/web_lab_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/progress_controller.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/ai/tutor_page.dart';
import 'features/ai/provider_page.dart';
import 'features/code/code_lab_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lessons.dart';
import 'lesson_guides.dart';
import 'features/learning/lesson_quiz.dart';
import 'features/learning/course_browser.dart';
import 'features/learning/learning_hub_page.dart';
import 'features/learning/attempt_history_page.dart';
import 'features/study/study_page.dart';
import 'features/study/reminders_page.dart';
import 'cloud_service.dart';
import 'auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CloudService.initialize();
  runApp(const CodingAcademyApp());
}

const _cyan = Color(0xFF72D7CE);

class CodingAcademyApp extends StatefulWidget {
  const CodingAcademyApp({super.key});

  @override
  State<CodingAcademyApp> createState() => _CodingAcademyAppState();
}

class _CodingAcademyAppState extends State<CodingAcademyApp> {
  bool english = false;
  bool dark = true;
  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        english = prefs.getBool('english_ui') ?? false;
        dark = prefs.getBool('dark_ui') ?? true;
      });
    }
  }

  Future<void> language(bool value) async {
    setState(() => english = value);
    await (await SharedPreferences.getInstance()).setBool('english_ui', value);
  }

  Future<void> theme(bool value) async {
    setState(() => dark = value);
    await (await SharedPreferences.getInstance()).setBool('dark_ui', value);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Myanmar AI Coding Academy',
    debugShowCheckedModeBanner: false,
    locale: Locale(english ? 'en' : 'my'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    theme: academyTheme(Brightness.light),
    darkTheme: academyTheme(Brightness.dark),
    home: AcademyShell(
      english: english,
      dark: dark,
      onLanguage: language,
      onTheme: theme,
    ),
  );
}

class AcademyShell extends StatefulWidget {
  const AcademyShell({
    super.key,
    required this.english,
    required this.dark,
    required this.onLanguage,
    required this.onTheme,
  });
  final bool english;
  final bool dark;
  final Future<void> Function(bool) onLanguage;
  final Future<void> Function(bool) onTheme;

  @override
  State<AcademyShell> createState() => _AcademyShellState();
}

class _AcademyShellState extends State<AcademyShell>
    with WidgetsBindingObserver {
  int tab = 0;
  String selectedTrack = 'all';
  final visitedTabs = <int>{0};
  bool get english => widget.english;
  Set<String> get completed => progress?.completed ?? {};
  ProgressController? progress;
  StreamSubscription<AuthState>? authSubscription;
  String? account;
  String? initialCode;
  String lessonContext = '';
  String codeContext = '';
  int editorVersion = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    account = CloudService.user?.id;
    if (CloudService.configured) {
      authSubscription = CloudService.authChanges.listen(
        (state) {
          if (!mounted) return;
          final next = state.session?.user.id;
          if (next != account) {
            setState(() {
              account = next;
              initialCode = null;
              lessonContext = '';
              codeContext = '';
              editorVersion++;
            });
            unawaited(progress?.activate(next));
          }
          if (state.event == AuthChangeEvent.passwordRecovery) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AuthPage(recovery: true),
              ),
            );
          }
        },
        onError: (Object _) {
          // SDK may report offline refresh errors. Do not erase local progress.
          if (mounted) setState(() {});
        },
      );
    }
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    progress = ProgressController(
      prefs: prefs,
      loadRemote: CloudService.loadProgress,
      saveRemote: CloudService.saveProgress,
    );
    progress!.addListener(_changed);
    await progress!.activate(account);
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(progress?.sync());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    authSubscription?.cancel();
    progress?.removeListener(_changed);
    progress?.dispose();
    super.dispose();
  }

  Future<void> _complete(Lesson lesson, String? owner) async {
    final controller = progress;
    if (controller == null) throw StateError('Progress not ready');
    await controller.complete(lesson.id, expectedUser: owner);
  }

  Future<void> _setLanguage(bool value) => widget.onLanguage(value);
  Future<void> _openCode(String code) async {
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
    setState(() {
      initialCode = code;
      editorVersion++;
      tab = 2;
      visitedTabs.add(2);
    });
  }

  void _askCode(String code) => setState(() {
    codeContext = code;
    lessonContext = '';
    tab = 3;
    visitedTabs.add(3);
  });

  void _openLearning(int initialTab) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LearningHubPage(
          account: account,
          completed: {...completed},
          initialTab: initialTab,
          onCode: (code) async {
            Navigator.of(context).popUntil((route) => route.isFirst);
            await _openCode(code);
          },
          onTutor: (code) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            _askCode(code);
          },
          onLesson: (id) {
            Navigator.of(context).popUntil((route) => route.isFirst);
            final lesson = academyLessons.firstWhere(
              (lesson) => lesson.id == id,
            );
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => LessonPage(
                  lesson: lesson,
                  english: english,
                  completed: completed.contains(id),
                  onComplete: _completionFor(lesson, account),
                  onCode: (code) => _lessonCode(lesson, code),
                  onTutor: () => setState(() {
                    lessonContext = lessonGuides[id]!.text(english)['body']!;
                    codeContext = lesson.code;
                    tab = 3;
                    visitedTabs.add(3);
                  }),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String tr(String my, String en) => english ? en : my;

  @override
  Widget build(BuildContext context) {
    final screens = [_home(), _courses(), _codeLab(), _aiTutor(), _profile()];
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    return Scaffold(
      appBar: keyboardOpen
          ? null
          : AppBar(
              title: Text(
                'Coding Academy',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => _setLanguage(!english),
                  child: Text(
                    english ? 'မြန်မာ' : 'EN',
                    style: const TextStyle(color: _cyan),
                  ),
                ),
              ],
            ),
      body: SafeArea(
        child: IndexedStack(
          index: tab,
          children: [
            for (var i = 0; i < screens.length; i++)
              visitedTabs.contains(i) ? screens[i] : const SizedBox.shrink(),
          ],
        ),
      ),
      bottomNavigationBar: keyboardOpen
          ? null
          : NavigationBar(
              selectedIndex: tab,
              onDestinationSelected: (value) => setState(() {
                if (tab == 2) initialCode = null;
                tab = value;
                visitedTabs.add(value);
              }),
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.home_outlined),
                  label: tr('မူလ', 'Home'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.school_outlined),
                  label: tr('သင်ခန်းစာ', 'Learn'),
                ),
                NavigationDestination(
                  icon: const Icon(Icons.code),
                  label: 'Code Lab',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.smart_toy_outlined),
                  label: 'AI Tutor',
                ),
                NavigationDestination(
                  icon: const Icon(Icons.person_outline),
                  label: tr('ပရိုဖိုင်', 'Profile'),
                ),
              ],
            ),
    );
  }

  void _learnTrack(String track) => setState(() {
    selectedTrack = track;
    tab = 1;
    visitedTabs.add(1);
  });
  void _openQuiz() => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => PracticeTestPage(account: account, english: english),
    ),
  );
  void _openHtml([String? html]) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => WebLabPage(account: account, initialHtml: html),
    ),
  );
  Future<void> _lessonCode(Lesson lesson, String code) async {
    if (lesson.language == 'html') {
      _openHtml(code);
      return;
    }
    if (lesson.language == 'python') {
      await _openCode(code);
      return;
    }
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'နမူနာကို ကူးပြီးပါပြီ။ Computer/VM lab တွင် လေ့ကျင့်ပါ။',
              'Example copied. Practice in your computer or VM lab.',
            ),
          ),
        ),
      );
  }

  Widget _home() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
    children: [
      Text(
        tr('တစ်နေ့ နည်းနည်းချင်း လေ့လာပါ', 'Build a little, learn a lot.'),
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      Text(
        tr(
          'ဖတ်ပါ၊ လေ့ကျင့်ပါ၊ ကိုယ့်တိုးတက်မှုကို ကြည့်ပါ။',
          'Read, practice, and see your progress.',
        ),
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 18),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      tr('သင့်လေ့လာမှု', 'YOUR LEARNING'),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ),
                  Text(
                    '${completed.length} / ${academyLessons.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: (completed.length / academyLessons.length).clamp(
                  0.0,
                  1.0,
                ),
                minHeight: 6,
                borderRadius: BorderRadius.circular(9),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _learnTrack(selectedTrack),
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(tr('ဆက်လက်လေ့လာမယ်', 'Continue learning')),
                ),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      Text(
        tr('ဘာသာရပ်များ', 'Explore subjects'),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 8),
      LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 700
              ? 3
              : constraints.maxWidth < 300
              ? 1
              : 2;
          final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;
          return Wrap(
            spacing: 12,
            runSpacing: 2,
            children: [
              for (final track in academyTracks)
                SizedBox(
                  width: width,
                  child: Card(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _learnTrack(track),
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              trackIcon(track),
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              trackLabel(track, english),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${academyLessons.where((l) => l.track == track).length} ${tr('သင်ခန်းစာ', 'lessons')}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      const SizedBox(height: 18),
      Text(
        tr('လေ့ကျင့်ရန်', 'Practice tools'),
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 6),
      Card(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.quiz_outlined),
              title: Text(tr('Q&A နှင့် Test Preview', 'Q&A & test preview')),
              trailing: const Icon(Icons.chevron_right),
              onTap: _openQuiz,
            ),
            const Divider(indent: 54),
            ListTile(
              leading: const Icon(Icons.web_outlined),
              title: const Text('HTML Viewer'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openHtml(),
            ),
            const Divider(indent: 54),
            ListTile(
              leading: const Icon(Icons.auto_awesome_outlined),
              title: const Text('AI Tutor'),
              subtitle: Text(
                tr(
                  'ကိုယ်ပိုင် provider ဖြင့် မေးမြန်းပါ',
                  'Ask with your own AI provider',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() {
                tab = 3;
                visitedTabs.add(3);
              }),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _infoCard(IconData icon, String title, String subtitle) => Card(
    child: ListTile(
      leading: Icon(icon, color: _cyan),
      title: Text(title),
      subtitle: Text(subtitle),
    ),
  );

  Widget _courses() => CourseBrowser(
    english: english,
    completed: completed,
    initialTrack: selectedTrack,
    actions: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: _openQuiz,
          icon: const Icon(Icons.quiz_outlined),
          label: Text(tr('Q&A စမ်းဖြေရန်', 'Q&A Practice')),
        ),
        OutlinedButton.icon(
          onPressed: () => _openLearning(0),
          icon: const Icon(Icons.route_outlined),
          label: Text(AppLocalizations.of(context)!.learningPaths),
        ),
        OutlinedButton.icon(
          onPressed: () => _openLearning(1),
          icon: const Icon(Icons.terminal),
          label: Text(AppLocalizations.of(context)!.codingChallenges),
        ),
        OutlinedButton.icon(
          onPressed: () => _openLearning(2),
          icon: const Icon(Icons.construction),
          label: Text(AppLocalizations.of(context)!.guidedProjects),
        ),
      ],
    ),
    onLesson: (lesson) => Navigator.of(context)
        .push(
          MaterialPageRoute<void>(
            builder: (_) => LessonPage(
              lesson: lesson,
              english: english,
              completed: completed.contains(lesson.id),
              onComplete: _completionFor(lesson, account),
              onCode: (code) => _lessonCode(lesson, code),
              onTutor: () => setState(() {
                lessonContext = lessonGuides[lesson.id]!.text(english)['body']!;
                codeContext = lesson.code;
                tab = 3;
                visitedTabs.add(3);
              }),
            ),
          ),
        )
        .then((_) {
          if (mounted) setState(() {});
        }),
  );

  Future<void> Function() _completionFor(Lesson lesson, String? owner) =>
      () => _complete(lesson, owner);

  Widget _codeLab() => CodeLabPage(
    key: ValueKey('code.$account.$editorVersion'),
    account: account,
    initialCode: initialCode,
    onAsk: _askCode,
  );
  Widget _aiTutor() => TutorPage(
    key: ValueKey('chat.$account'),
    account: account,
    onCode: _openCode,
    lessonContext: lessonContext,
    codeContext: codeContext,
  );

  Widget _profile() {
    final l = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.person_outline),
            ),
            title: Text(
              CloudService.user?.email ?? l.guest,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              tr('သင့်ကိုယ်ပိုင် လေ့လာမှုနေရာ', 'Your learning space'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.timer_outlined),
            title: Text(
              tr('လေ့လာချိန်နှင့် မှတ်တမ်း', 'Study timer and history'),
            ),
            subtitle: Text(
              tr(
                'Foreground လေ့လာချိန်နှင့် အပတ်စဉ်အနှစ်ချုပ်',
                'Foreground time and weekly summary',
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => StudyPage(
                  key: ValueKey('study.$account'),
                  account: account,
                  english: english,
                ),
              ),
            ),
          ),
        ),
        Card(
          child: ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: Text(tr('နေ့စဉ် Reminder', 'Daily reminders')),
            subtitle: Text(
              tr(
                'အချိန်၊ နေ့ရက်နှင့် လေ့လာချိန် ရွေးချယ်ရန်',
                'Choose time, weekdays and study duration',
              ),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => RemindersPage(
                  key: ValueKey('reminder.$account'),
                  account: account,
                  english: english,
                ),
              ),
            ),
          ),
        ),
        if (CloudService.configured)
          FilledButton.icon(
            icon: Icon(account == null ? Icons.login : Icons.logout),
            label: Text(account == null ? l.signIn : l.signOut),
            onPressed: () async {
              try {
                if (account == null) {
                  await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const AuthPage()),
                  );
                } else {
                  await CloudService.signOut();
                }
              } catch (_) {
                if (mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.authFailed)));
                }
              }
            },
          ),
        ListTile(
          leading: const Icon(Icons.key),
          title: Text(l.byokSettings),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => ProviderPage(account: account),
            ),
          ),
        ),
        if (account != null) ...[
          ListTile(
            leading: const Icon(Icons.fact_check_outlined),
            title: Text(l.assessmentHistory),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => AttemptHistoryPage(account: account!),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(
              progress?.syncing == true
                  ? l.syncing
                  : progress?.syncFailed == true
                  ? l.syncFailed
                  : l.sync,
            ),
            onTap: progress?.syncing == true ? null : () => progress?.sync(),
          ),
        ],
        ListTile(
          leading: const Icon(Icons.quiz_outlined),
          title: Text(tr('Q&A စမ်းဖြေရလဒ်များ', 'Q&A practice & results')),
          trailing: const Icon(Icons.chevron_right),
          onTap: _openQuiz,
        ),
        _infoCard(
          Icons.check_circle_outline,
          tr('ပြီးဆုံးသင်ခန်းစာ', 'Lessons completed'),
          '${completed.length} / ${academyLessons.length}',
        ),
        ExpansionTile(
          title: Text(
            tr('Account နှင့် Sync အကြောင်း', 'Account & sync details'),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l.cloudNotice),
            ),
          ],
        ),
        SwitchListTile(
          title: const Text('မြန်မာ / English'),
          value: english,
          onChanged: _setLanguage,
        ),
        SwitchListTile(
          title: Text(l.darkMode),
          value: widget.dark,
          onChanged: widget.onTheme,
        ),
      ],
    );
  }
}

class LessonPage extends StatefulWidget {
  const LessonPage({
    super.key,
    required this.lesson,
    required this.english,
    required this.completed,
    required this.onComplete,
    required this.onCode,
    required this.onTutor,
  });
  final Lesson lesson;
  final bool english;
  final bool completed;
  final Future<void> Function() onComplete;
  final Future<void> Function(String) onCode;
  final VoidCallback onTutor;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late bool completed = widget.completed;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    final l = AppLocalizations.of(context)!;
    final guide = lessonGuides[lesson.id]!;
    final text = guide.text(widget.english);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.english ? lesson.titleEn : lesson.titleMy),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '${lesson.titleEn} · ${courseLevel(lesson.level, widget.english)}',
            style: const TextStyle(color: _cyan),
          ),
          if (lesson.prerequisites.isNotEmpty)
            Text(
              '${widget.english ? 'Recommended first' : 'အရင်လေ့လာရန်'}: ${lesson.prerequisites.join(', ')}',
            ),
          if (lesson.environment == 'computer')
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  widget.english
                      ? 'Computer / VM lab. Read and copy on your phone; practice with the indicated tools in your own computer environment.'
                      : 'Computer / VM lab အတွက် ဖြစ်သည်။ ဖုန်းတွင် ဖတ်ပြီး ကူးနိုင်သည်။ ကိုယ့်စက်ပေါ်ရှိ သတ်မှတ် tool များဖြင့် လေ့ကျင့်ပါ။',
                ),
              ),
            ),
          if (lesson.flow.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                for (var i = 0; i < lesson.flow.length; i++) ...[
                  Chip(label: Text(lesson.flow[i])),
                  if (i < lesson.flow.length - 1)
                    const Icon(Icons.arrow_forward, size: 18),
                ],
              ],
            ),
          ],
          const SizedBox(height: 18),
          Text(l.objectives, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(text['objectives']!),
          const SizedBox(height: 18),
          Text(
            text['body']!,
            style: const TextStyle(fontSize: 15, height: 1.75),
          ),
          const SizedBox(height: 24),
          Text(
            widget.english ? 'Code example' : 'Code နမူနာ',
            style: TextStyle(color: _cyan, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(
              lesson.code,
              style: const TextStyle(fontFamily: 'monospace', height: 1.6),
            ),
          ),
          const SizedBox(height: 16),
          Text(l.lineByLine, style: Theme.of(context).textTheme.titleLarge),
          Text(text['lines']!, style: const TextStyle(height: 1.7)),
          const SizedBox(height: 16),
          Text(l.commonMistakes, style: Theme.of(context).textTheme.titleLarge),
          Text(text['mistake']!, style: const TextStyle(height: 1.7)),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onCode(lesson.code);
            },
            icon: const Icon(Icons.code),
            label: Text(
              lesson.language == 'html'
                  ? 'HTML Viewer'
                  : lesson.language == 'python'
                  ? l.insertCode
                  : (widget.english ? 'Copy example' : 'နမူနာကူးရန်'),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onTutor();
            },
            icon: const Icon(Icons.smart_toy_outlined),
            label: const Text('AI Tutor'),
          ),
          const SizedBox(height: 24),
          Text(
            widget.english ? 'Practice challenge' : 'လေ့ကျင့်ရန်',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(text['challenge']!, style: const TextStyle(height: 1.7)),
          ExpansionTile(
            title: Text(l.hints),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(text['hint']!),
              ),
            ],
          ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onCode(lesson.code);
            },
            icon: const Icon(Icons.edit_note),
            label: Text(
              lesson.language == 'html'
                  ? 'HTML Viewer'
                  : lesson.language == 'python'
                  ? l.startExercise
                  : (widget.english
                        ? 'Copy for computer lab'
                        : 'Computer lab အတွက် ကူးရန်'),
            ),
          ),
          const SizedBox(height: 12),
          ExpansionTile(
            title: Text(
              widget.english ? 'View sample answer' : 'နမူနာအဖြေ ကြည့်ရန်',
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  lesson.answer,
                  style: const TextStyle(fontFamily: 'monospace'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          LessonQuiz(
            key: ValueKey(lesson.id),
            lessonId: lesson.id,
            guide: guide,
            english: widget.english,
          ),
          const SizedBox(height: 16),
          Text(l.references, style: Theme.of(context).textTheme.titleMedium),
          SelectableText(guide.reference),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: completed
                ? null
                : () async {
                    try {
                      await widget.onComplete();
                      if (mounted) setState(() => completed = true);
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.sessionExpired,
                            ),
                          ),
                        );
                      }
                    }
                  },
            icon: Icon(completed ? Icons.check_circle : Icons.done),
            label: Text(
              completed
                  ? (widget.english ? 'Completed' : 'ပြီးဆုံးပါပြီ')
                  : (widget.english
                        ? 'Mark lesson completed'
                        : 'သင်ခန်းစာ ပြီးဆုံးအဖြစ် မှတ်သားရန်'),
            ),
          ),
        ],
      ),
    );
  }
}
