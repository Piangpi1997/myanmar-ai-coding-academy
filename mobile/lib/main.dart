import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/progress_controller.dart';
import 'l10n/generated/app_localizations.dart';
import 'features/ai/tutor_page.dart';
import 'features/ai/provider_page.dart';
import 'features/code/code_lab_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'lessons.dart';
import 'cloud_service.dart';
import 'auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CloudService.initialize();
  runApp(const CodingAcademyApp());
}

const _background = Color(0xFF080D1B);
const _panel = Color(0xFF111B2E);
const _purple = Color(0xFF775CFF);
const _cyan = Color(0xFF00D9E8);

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
    theme: ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(seedColor: _purple),
      fontFamily: 'NotoSansMyanmar',
    ),
    darkTheme: ThemeData(
      fontFamily: 'NotoSansMyanmar',
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: _background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _purple,
        brightness: Brightness.dark,
        surface: _panel,
      ),
      appBarTheme: const AppBarTheme(backgroundColor: _background),
      cardTheme: CardThemeData(color: _panel, elevation: 0),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _panel,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    ),
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

  String tr(String my, String en) => english ? en : my;

  @override
  Widget build(BuildContext context) {
    final screens = [_home(), _courses(), _codeLab(), _aiTutor(), _profile()];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          tr('မြန်မာ AI Coding Academy', 'Myanmar AI Coding Academy'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
      bottomNavigationBar: NavigationBar(
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

  Widget _home() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const SizedBox(height: 8),
      Text(
        tr('Coding ကို ဒီနေ့ စလိုက်ပါ!', 'Start coding today!'),
        style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Text(
        tr(
          'အခြေခံမှ ပရော်ဖက်ရှင်နယ်အထိ တစ်ဆင့်ချင်း လေ့လာပါ။',
          'Learn step by step, from zero to professional skills.',
        ),
      ),
      const SizedBox(height: 24),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('PYTHON ZERO TO HERO', style: TextStyle(color: _cyan)),
              const SizedBox(height: 12),
              Text(
                '${completed.length} / ${pythonLessons.length} ${tr('သင်ခန်းစာ ပြီးဆုံး', 'lessons completed')}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: completed.length / pythonLessons.length,
                minHeight: 9,
                borderRadius: BorderRadius.circular(12),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => setState(() {
                  tab = 1;
                  visitedTabs.add(1);
                }),
                icon: const Icon(Icons.arrow_forward),
                label: Text(tr('ဆက်လက်လေ့လာမယ်', 'Continue learning')),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 16),
      _infoCard(
        Icons.auto_awesome,
        tr('AI Tutor', 'AI Tutor'),
        tr(
          'ကိုယ်ပိုင် API key ဖြင့် မြန်မာလို မေးမြန်းလေ့လာပါ။',
          'Learn with your own provider and API key.',
        ),
      ),
      _infoCard(
        Icons.terminal,
        'Code Lab',
        tr(
          'Python ရေးပြီး ချိတ်ဆက်ထားသော sandbox တွင် run ပါ။',
          'Write Python and run it in a configured remote sandbox.',
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

  Widget _courses() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Text(
        tr('Python သင်ခန်းစာများ', 'Python Lessons'),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
      ),
      const SizedBox(height: 8),
      Text(
        tr(
          'Starter Course — အခြေခံ သင်ခန်းစာ ၁၀ ခု',
          'Starter course — 10 introductory lessons',
        ),
      ),
      const SizedBox(height: 14),
      for (var i = 0; i < pythonLessons.length; i++)
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: completed.contains(pythonLessons[i].id)
                  ? Colors.green
                  : _purple,
              child: completed.contains(pythonLessons[i].id)
                  ? const Icon(Icons.check)
                  : Text('${i + 1}'),
            ),
            title: Text(
              english ? pythonLessons[i].titleEn : pythonLessons[i].titleMy,
            ),
            subtitle: Text(pythonLessons[i].summaryMy, maxLines: 2),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context)
                .push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonPage(
                      lesson: pythonLessons[i],
                      english: english,
                      completed: completed.contains(pythonLessons[i].id),
                      onComplete: _completionFor(pythonLessons[i], account),
                      onCode: _openCode,
                      onTutor: () => setState(() {
                        lessonContext = pythonLessons[i].bodyMy;
                        codeContext = pythonLessons[i].code;
                        tab = 3;
                        visitedTabs.add(3);
                      }),
                    ),
                  ),
                )
                .then((_) {
                  if (mounted) setState(() {});
                }),
          ),
        ),
    ],
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
        const CircleAvatar(
          radius: 42,
          backgroundColor: _purple,
          child: Icon(Icons.person, size: 42),
        ),
        const SizedBox(height: 20),
        Text(
          CloudService.user?.email ?? l.guest,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Text(l.cloudNotice, textAlign: TextAlign.center),
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
        if (account != null) ...[
          ListTile(
            leading: const Icon(Icons.key),
            title: Text(l.byokSettings),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => ProviderPage(account: account!),
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
        _infoCard(
          Icons.check_circle_outline,
          tr('ပြီးဆုံးသင်ခန်းစာ', 'Lessons completed'),
          '${completed.length} / ${pythonLessons.length}',
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.english ? lesson.titleEn : lesson.titleMy),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(lesson.titleEn, style: const TextStyle(color: _cyan)),
          const SizedBox(height: 18),
          Text(
            lesson.bodyMy,
            style: const TextStyle(fontSize: 17, height: 1.8),
          ),
          const SizedBox(height: 24),
          const Text(
            'CODE EXAMPLE',
            style: TextStyle(color: _cyan, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SelectableText(
              lesson.code,
              style: const TextStyle(fontFamily: 'monospace', height: 1.6),
            ),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              widget.onCode(lesson.code);
            },
            icon: const Icon(Icons.code),
            label: Text(AppLocalizations.of(context)!.insertCode),
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
          Text(lesson.challengeMy, style: const TextStyle(height: 1.7)),
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
