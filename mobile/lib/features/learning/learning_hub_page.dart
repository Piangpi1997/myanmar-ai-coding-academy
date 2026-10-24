import 'dart:async';
import 'package:flutter/material.dart';
import '../../cloud_service.dart';
import '../../core/secure_store.dart';
import '../../lessons.dart';
import '../../l10n/generated/app_localizations.dart';
import 'learning_catalog.dart';
import 'project_page.dart';
import 'exercise_page.dart';

class LearningHubPage extends StatefulWidget {
  const LearningHubPage({
    super.key,
    required this.account,
    required this.completed,
    required this.onLesson,
    required this.onCode,
    required this.onTutor,
    this.initialTab = 0,
    this.loadCatalog = LearningCatalog.load,
  });
  final String? account;
  final Set<String> completed;
  final ValueChanged<String> onLesson;
  final Future<void> Function(String) onCode;
  final ValueChanged<String> onTutor;
  final int initialTab;
  final Future<LearningCatalog> Function() loadCatalog;
  @override
  State<LearningHubPage> createState() => _LearningHubPageState();
}

class _LearningHubPageState extends State<LearningHubPage> {
  LearningCatalog? catalog;
  bool failed = false, changedAccount = false;
  StreamSubscription? authSubscription;
  String search = '', level = 'all';
  String? selectedPath;
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
    } else {
      load();
    }
  }

  @override
  void dispose() {
    authSubscription?.cancel();
    super.dispose();
  }

  Future<void> load() async {
    try {
      final data = await widget.loadCatalog();
      final selected = await secureStorage.read(
        key: 'learning-path.v1.${widget.account ?? 'guest'}',
      );
      if (mounted) {
        setState(() {
          catalog = data;
          selectedPath = selected;
          failed = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => failed = true);
    }
  }

  bool matches(LocalizedText title) =>
      '${title.my} ${title.en}'.toLowerCase().contains(search.toLowerCase());
  void openExercise(PracticeExercise exercise) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ExercisePage(
        exercise: exercise,
        account: widget.account,
        onTutor: widget.onTutor,
      ),
    ),
  );
  void openProject(ProjectGuide project) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ProjectPage(
        project: project,
        account: widget.account,
        onCode: widget.onCode,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final data = catalog;
    return DefaultTabController(
      length: 3,
      initialIndex: widget.initialTab,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l.learningHub),
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: l.learningPaths),
              Tab(text: l.codingChallenges),
              Tab(text: l.guidedProjects),
            ],
          ),
        ),
        body: changedAccount
            ? Center(child: Text(l.sessionExpired))
            : data == null
            ? failed
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(l.catalogError),
                          TextButton(onPressed: load, child: Text(l.retry)),
                        ],
                      ),
                    )
                  : const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      onChanged: (v) => setState(() => search = v),
                      decoration: InputDecoration(
                        labelText: l.searchLearning,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            Text(l.pathNotice),
                            for (final path in data.paths.where(
                              (p) => matches(p.title),
                            ))
                              Card(
                                child: ListTile(
                                  leading: Icon(
                                    selectedPath == path.id
                                        ? Icons.bookmark
                                        : Icons.route_outlined,
                                  ),
                                  title: Text(path.title.inLanguage(english)),
                                  subtitle: Text(path.goal.inLanguage(english)),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute<void>(
                                        builder: (_) => LearningPathPage(
                                          path: path,
                                          catalog: data,
                                          account: widget.account,
                                          completed: widget.completed,
                                          onLesson: widget.onLesson,
                                          onExercise: openExercise,
                                          onProject: openProject,
                                        ),
                                      ),
                                    );
                                    if (mounted) load();
                                  },
                                ),
                              ),
                          ],
                        ),
                        ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            Text(l.assessmentNotice),
                            for (final exercise in data.exercises.where(
                              (e) => matches(e.title),
                            ))
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.terminal),
                                  title: Text(
                                    exercise.title.inLanguage(english),
                                  ),
                                  subtitle: Text(
                                    exercise.statement.inLanguage(english),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => openExercise(exercise),
                                ),
                              ),
                          ],
                        ),
                        ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          children: [
                            DropdownButtonFormField<String>(
                              initialValue: level,
                              decoration: InputDecoration(
                                labelText: l.projectLevel,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'all',
                                  child: Text(l.allLevels),
                                ),
                                DropdownMenuItem(
                                  value: 'beginner',
                                  child: Text(l.beginnerLevel),
                                ),
                                DropdownMenuItem(
                                  value: 'intermediate',
                                  child: Text(l.intermediateLevel),
                                ),
                                DropdownMenuItem(
                                  value: 'advanced',
                                  child: Text(l.advancedLevel),
                                ),
                              ],
                              onChanged: (v) => setState(() => level = v!),
                            ),
                            const SizedBox(height: 8),
                            Text(l.projectProgressNotice),
                            for (final project in data.projects.where(
                              (p) =>
                                  matches(p.title) &&
                                  (level == 'all' || level == p.level),
                            ))
                              Card(
                                child: ListTile(
                                  leading: const Icon(Icons.construction),
                                  title: Text(
                                    project.title.inLanguage(english),
                                  ),
                                  subtitle: Text(
                                    project.objective.inLanguage(english),
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => openProject(project),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class LearningPathPage extends StatelessWidget {
  const LearningPathPage({
    super.key,
    required this.path,
    required this.catalog,
    required this.account,
    required this.completed,
    required this.onLesson,
    required this.onExercise,
    required this.onProject,
  });
  final LearningPath path;
  final LearningCatalog catalog;
  final String? account;
  final Set<String> completed;
  final ValueChanged<String> onLesson;
  final ValueChanged<PracticeExercise> onExercise;
  final ValueChanged<ProjectGuide> onProject;
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final english = Localizations.localeOf(context).languageCode == 'en';
    final count = completed.intersection(path.lessonIds.toSet()).length;
    return Scaffold(
      appBar: AppBar(title: Text(path.title.inLanguage(english))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            path.goal.inLanguage(english),
            style: const TextStyle(height: 1.7),
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: count / path.lessonIds.length),
          Text('$count / ${path.lessonIds.length}'),
          FilledButton.icon(
            icon: const Icon(Icons.bookmark_add_outlined),
            label: Text(l.choosePath),
            onPressed: () async {
              if (CloudService.user?.id != account) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l.sessionExpired)));
                return;
              }
              try {
                await secureStorage.write(
                  key: 'learning-path.v1.${account ?? 'guest'}',
                  value: path.id,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.saved)));
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(l.storageError)));
                }
              }
            },
          ),
          const SizedBox(height: 16),
          Text(
            l.foundationLessons,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (final lesson in pythonLessons.where(
            (lesson) => path.lessonIds.contains(lesson.id),
          ))
            ListTile(
              leading: Icon(
                completed.contains(lesson.id)
                    ? Icons.check_circle
                    : Icons.menu_book_outlined,
              ),
              title: Text(english ? lesson.titleEn : lesson.titleMy),
              onTap: () => onLesson(lesson.id),
            ),
          const SizedBox(height: 16),
          Text(
            l.codingChallenges,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          for (final exercise in catalog.exercises.where(
            (e) => path.exerciseIds.contains(e.id),
          ))
            ListTile(
              title: Text(exercise.title.inLanguage(english)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onExercise(exercise),
            ),
          const SizedBox(height: 16),
          Text(l.guidedProjects, style: Theme.of(context).textTheme.titleLarge),
          for (final project in catalog.projects.where(
            (p) => path.projectIds.contains(p.id),
          ))
            ListTile(
              title: Text(project.title.inLanguage(english)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onProject(project),
            ),
        ],
      ),
    );
  }
}
