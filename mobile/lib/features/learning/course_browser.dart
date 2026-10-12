import 'package:flutter/material.dart';
import '../../lessons.dart';
import '../../lesson_guides.dart';

String courseLevel(String level, bool english) => switch (level) {
  'beginner' => english ? 'Beginner' : 'အခြေခံ',
  'intermediate' => english ? 'Intermediate' : 'အလယ်အလတ်',
  'advanced' => english ? 'Advanced' : 'အဆင့်မြင့်',
  'professional' => english ? 'Professional' : 'လုပ်ငန်းခွင်',
  _ => english ? 'All levels' : 'အဆင့်အားလုံး',
};

class CourseBrowser extends StatefulWidget {
  const CourseBrowser({
    super.key,
    required this.english,
    required this.completed,
    required this.actions,
    required this.onLesson,
  });
  final bool english;
  final Set<String> completed;
  final Widget actions;
  final ValueChanged<Lesson> onLesson;
  @override
  State<CourseBrowser> createState() => _CourseBrowserState();
}

class _CourseBrowserState extends State<CourseBrowser> {
  final search = TextEditingController();
  String level = 'all';
  bool unfinished = false;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.english;
    final query = search.text.trim().toLowerCase();
    final visible = pythonLessons
        .where(
          (lesson) =>
              (level == 'all' || lesson.level == level) &&
              (!unfinished || !widget.completed.contains(lesson.id)) &&
              '${lesson.id} ${lesson.titleMy} ${lesson.titleEn}'
                  .toLowerCase()
                  .contains(query),
        )
        .toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: visible.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                en ? 'Python Lessons' : 'Python သင်ခန်းစာများ',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                en
                    ? '${pythonLessons.length} original bilingual lessons'
                    : 'မြန်မာ / English သင်ခန်းစာ ${pythonLessons.length} ခု',
              ),
              const SizedBox(height: 12),
              widget.actions,
              const SizedBox(height: 12),
              TextField(
                controller: search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: en ? 'Search lessons' : 'သင်ခန်းစာ ရှာရန်',
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: level,
                decoration: InputDecoration(
                  labelText: en ? 'Course level' : 'သင်ခန်းစာအဆင့်',
                ),
                items:
                    [
                          'all',
                          'beginner',
                          'intermediate',
                          'advanced',
                          'professional',
                        ]
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(courseLevel(value, en)),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => level = value ?? 'all'),
              ),
              FilterChip(
                label: Text(en ? 'Not completed' : 'မပြီးသေးသော သင်ခန်းစာများ'),
                selected: unfinished,
                onSelected: (value) => setState(() => unfinished = value),
              ),
              Text(
                en
                    ? '${visible.length} lessons shown'
                    : 'သင်ခန်းစာ ${visible.length} ခု တွေ့သည်',
              ),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    en
                        ? 'No lessons match these filters.'
                        : 'ရှာဖွေမှုနှင့် ကိုက်သောသင်ခန်းစာ မရှိပါ။',
                  ),
                ),
            ],
          );
        }
        final lesson = visible[index - 1];
        final done = widget.completed.contains(lesson.id);
        return Card(
          child: ListTile(
            leading: CircleAvatar(
              child: done
                  ? const Icon(Icons.check)
                  : Text(lesson.id.substring(3)),
            ),
            title: Text(en ? lesson.titleEn : lesson.titleMy),
            subtitle: Text(
              '${courseLevel(lesson.level, en)} · ${lessonGuides[lesson.id]!.text(en)['objectives']}',
              maxLines: 3,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => widget.onLesson(lesson),
          ),
        );
      },
    );
  }
}
