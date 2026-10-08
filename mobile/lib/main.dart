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

class CodingAcademyApp extends StatelessWidget {
  const CodingAcademyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Myanmar AI Coding Academy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
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
        home: const AcademyShell(),
      );
}

class AcademyShell extends StatefulWidget {
  const AcademyShell({super.key});

  @override
  State<AcademyShell> createState() => _AcademyShellState();
}

class _AcademyShellState extends State<AcademyShell> {
  int tab = 0;
  bool english = false;
  Set<String> completed = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      final key = CloudService.user == null ? 'completed_lessons' : 'completed_${CloudService.user!.id}';
      completed = prefs.getStringList(key)?.toSet() ?? {};
      english = prefs.getBool('english_ui') ?? false;
    });
    await _refreshCloud();
  }

  Future<void> _refreshCloud() async {
    if (CloudService.user == null || !CloudService.apiConfigured) return;
    try {
      final serverProgress = await CloudService.loadProgress();
      if (serverProgress == null) return;
      // Cloud users do not inherit progress from guest or other accounts.
      final prefs = await SharedPreferences.getInstance();
      final key = 'completed_${CloudService.user!.id}';
      await prefs.setStringList(key, serverProgress.toList());
      if (mounted) setState(() => completed = serverProgress);
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cloud sync unavailable: $error')),
      );
    }
  }

  Future<void> _complete(Lesson lesson) async {
    final next = {...completed, lesson.id};
    final prefs = await SharedPreferences.getInstance();
    final key = CloudService.user == null ? 'completed_lessons' : 'completed_${CloudService.user!.id}';
    await prefs.setStringList(key, next.toList());
    if (mounted) setState(() => completed = next);
    if (CloudService.user != null && CloudService.apiConfigured) {
      try {
        await CloudService.saveProgress(lesson.id);
      } catch (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved locally; cloud sync failed: $error')),
        );
      }
    }
  }

  Future<void> _setLanguage(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('english_ui', value);
    if (mounted) setState(() => english = value);
  }

  String tr(String my, String en) => english ? en : my;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _home(),
      _courses(),
      _codeLab(),
      _aiTutor(),
      _profile(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(tr('မြန်မာ AI Coding Academy', 'Myanmar AI Coding Academy'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => _setLanguage(!english),
            child: Text(english ? 'မြန်မာ' : 'EN', style: const TextStyle(color: _cyan)),
          ),
        ],
      ),
      body: SafeArea(child: screens[tab]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (value) => setState(() => tab = value),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), label: tr('မူလ', 'Home')),
          NavigationDestination(icon: const Icon(Icons.school_outlined), label: tr('သင်ခန်းစာ', 'Learn')),
          NavigationDestination(icon: const Icon(Icons.code), label: 'Code Lab'),
          NavigationDestination(icon: const Icon(Icons.smart_toy_outlined), label: 'AI Tutor'),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: tr('ပရိုဖိုင်', 'Profile')),
        ],
      ),
    );
  }

  Widget _home() => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          Text(tr('Coding ကို ဒီနေ့ စလိုက်ပါ!', 'Start coding today!'),
              style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(tr('အခြေခံမှ ပရော်ဖက်ရှင်နယ်အထိ တစ်ဆင့်ချင်း လေ့လာပါ။',
              'Learn step by step, from zero to professional skills.')),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('PYTHON ZERO TO HERO', style: TextStyle(color: _cyan)),
                const SizedBox(height: 12),
                Text('${completed.length} / ${pythonLessons.length} ' +
                    tr('သင်ခန်းစာ ပြီးဆုံး', 'lessons completed'),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                LinearProgressIndicator(value: completed.length / pythonLessons.length,
                    minHeight: 9, borderRadius: BorderRadius.circular(12)),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => setState(() => tab = 1),
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(tr('ဆက်လက်လေ့လာမယ်', 'Continue learning')),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          _infoCard(Icons.auto_awesome, tr('AI Tutor', 'AI Tutor'),
              tr('AI API ချိတ်ဆက်မှုကို နောက် Phase တွင် ထည့်သွင်းမည်။',
                  'AI API integration is planned for a later phase.')),
          _infoCard(Icons.terminal, 'Code Lab',
              tr('Code editor နှင့် Sandbox Run စနစ်ကို နောက် Phase တွင် ထည့်သွင်းမည်။',
                  'Live sandbox execution is planned for a later phase.')),
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
          Text(tr('Python သင်ခန်းစာများ', 'Python Lessons'),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          const SizedBox(height: 8),
          Text(tr('Starter Course — အခြေခံ သင်ခန်းစာ ၁၀ ခု',
              'Starter course — 10 introductory lessons')),
          const SizedBox(height: 14),
          for (var i = 0; i < pythonLessons.length; i++)
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: completed.contains(pythonLessons[i].id) ? Colors.green : _purple,
                  child: completed.contains(pythonLessons[i].id)
                      ? const Icon(Icons.check)
                      : Text('${i + 1}'),
                ),
                title: Text(english ? pythonLessons[i].titleEn : pythonLessons[i].titleMy),
                subtitle: Text(pythonLessons[i].summaryMy, maxLines: 2),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => LessonPage(
                      lesson: pythonLessons[i],
                      english: english,
                      completed: completed.contains(pythonLessons[i].id),
                      onComplete: () => _complete(pythonLessons[i]),
                    ),
                  ),
                ).then((_) { if (mounted) setState(() {}); }),
              ),
            ),
        ],
      );

  Widget _codeLab() => const _ComingSoon(
        icon: Icons.terminal,
        title: 'Code Lab',
        description: 'Live Python execution is not connected yet. A secured remote sandbox and real editor will be implemented in Phase 2.',
      );

  Widget _aiTutor() => const _ComingSoon(
        icon: Icons.smart_toy_outlined,
        title: 'AI Tutor',
        description: 'The AI chat API is not connected yet. Phase 3 will add authenticated, Myanmar-first tutoring.',
      );

  Widget _profile() => ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const CircleAvatar(radius: 42, backgroundColor: _purple,
              child: Icon(Icons.person, size: 42)),
          const SizedBox(height: 20),
          Text(CloudService.user?.email ?? tr('ဧည့်သည်အဖြစ် အသုံးပြုနေသည်', 'Using guest mode'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(tr('Login နှင့် Cloud Sync ကို Phase 1 backend ချိတ်ဆက်သည့်အခါ ထည့်သွင်းမည်။',
              'Login and cloud sync are not connected yet.'),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          if (CloudService.configured) FilledButton.icon(
            icon: Icon(CloudService.user == null ? Icons.login : Icons.logout),
            label: Text(CloudService.user == null ? 'Sign in / Sign up' : 'Sign out'),
            onPressed: () async {
              if (CloudService.user == null) {
                final signedIn = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const AuthPage()),
                );
                if (signedIn == true) {
                  final prefs = await SharedPreferences.getInstance();
                  if (mounted) setState(() => completed = prefs.getStringList('completed_${CloudService.user!.id}')?.toSet() ?? {});
                  await _refreshCloud();
                }
              } else {
                await CloudService.signOut();
                final prefs = await SharedPreferences.getInstance();
                if (mounted) setState(() => completed = prefs.getStringList('completed_lessons')?.toSet() ?? {});
              }
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(height: 24),
          _infoCard(Icons.check_circle_outline, tr('ပြီးဆုံးသင်ခန်းစာ', 'Lessons completed'),
              '${completed.length} / ${pythonLessons.length}'),
          SwitchListTile(
            title: Text(tr('English Interface', 'English Interface')),
            subtitle: Text('Myanmar / English'),
            value: english,
            onChanged: _setLanguage,
          ),
        ],
      );
}

class LessonPage extends StatefulWidget {
  const LessonPage({
    super.key,
    required this.lesson,
    required this.english,
    required this.completed,
    required this.onComplete,
  });
  final Lesson lesson;
  final bool english;
  final bool completed;
  final Future<void> Function() onComplete;

  @override
  State<LessonPage> createState() => _LessonPageState();
}

class _LessonPageState extends State<LessonPage> {
  late bool completed = widget.completed;

  @override
  Widget build(BuildContext context) {
    final lesson = widget.lesson;
    return Scaffold(
      appBar: AppBar(title: Text(widget.english ? lesson.titleEn : lesson.titleMy)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(lesson.titleEn, style: const TextStyle(color: _cyan)),
          const SizedBox(height: 18),
          Text(lesson.bodyMy, style: const TextStyle(fontSize: 17, height: 1.8)),
          const SizedBox(height: 24),
          const Text('CODE EXAMPLE', style: TextStyle(color: _cyan, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: _panel, borderRadius: BorderRadius.circular(16)),
            child: SelectableText(lesson.code, style: const TextStyle(fontFamily: 'monospace', height: 1.6)),
          ),
          const SizedBox(height: 24),
          Text(widget.english ? 'Practice challenge' : 'လေ့ကျင့်ရန်',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(lesson.challengeMy, style: const TextStyle(height: 1.7)),
          const SizedBox(height: 12),
          ExpansionTile(
            title: Text(widget.english ? 'View sample answer' : 'နမူနာအဖြေ ကြည့်ရန်'),
            children: [Padding(
              padding: const EdgeInsets.all(12),
              child: SelectableText(lesson.answer, style: const TextStyle(fontFamily: 'monospace')),
            )],
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: completed ? null : () async {
              await widget.onComplete();
              if (mounted) setState(() => completed = true);
            },
            icon: Icon(completed ? Icons.check_circle : Icons.done),
            label: Text(completed
                ? (widget.english ? 'Completed' : 'ပြီးဆုံးပါပြီ')
                : (widget.english ? 'Mark lesson completed' : 'သင်ခန်းစာ ပြီးဆုံးအဖြစ် မှတ်သားရန်')),
          ),
        ],
      ),
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _cyan, size: 70),
              const SizedBox(height: 18),
              Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(description, textAlign: TextAlign.center,
                  style: const TextStyle(height: 1.6)),
              const SizedBox(height: 16),
              const Chip(label: Text('Planned — not yet functional')),
            ],
          ),
        ),
      );
}
