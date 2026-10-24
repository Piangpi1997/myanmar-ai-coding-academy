import 'package:flutter/material.dart';
import '../../lessons.dart';
import 'academy_tracks.dart';

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
    this.initialTrack = 'all',
  });
  final bool english;
  final Set<String> completed;
  final Widget actions;
  final ValueChanged<Lesson> onLesson;
  final String initialTrack;
  @override
  State<CourseBrowser> createState() => _CourseBrowserState();
}

class _CourseBrowserState extends State<CourseBrowser> {
  final search = TextEditingController();
  String level = 'all';
  late String track = widget.initialTrack;
  bool unfinished = false;
  @override
  void didUpdateWidget(covariant CourseBrowser oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTrack != widget.initialTrack)
      track = widget.initialTrack;
  }

  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final en = widget.english;
    final query = search.text.trim().toLowerCase();
    final visible = academyLessons
        .where(
          (lesson) =>
              (track == 'all' || lesson.track == track) &&
              (level == 'all' || lesson.level == level) &&
              (!unfinished || !widget.completed.contains(lesson.id)) &&
              '${lesson.id} ${lesson.titleMy} ${lesson.titleEn}'
                  .toLowerCase()
                  .contains(query),
        )
        .toList();
    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      itemCount: visible.length + 1,
      itemBuilder: (context, index) {
        if (index == 0)
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                en ? 'Lesson library' : 'သင်ခန်းစာ စာကြည့်တိုက်',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                en
                    ? '${academyLessons.length} lessons · 5 subjects · offline reading'
                    : 'သင်ခန်းစာ ${academyLessons.length} ခု · ဘာသာရပ် ၅ မျိုး · Offline ဖတ်နိုင်',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 18),
              TextField(
                controller: search,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: en ? 'Search lessons' : 'သင်ခန်းစာ ရှာရန်',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: en ? 'Clear search' : 'ရှာဖွေစာ ဖျက်ရန်',
                          onPressed: () => setState(search.clear),
                          icon: const Icon(Icons.close),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final value in ['all', ...academyTracks])
                      Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChoiceChip(
                          label: Text(trackLabel(value, en)),
                          selected: track == value,
                          onSelected: (_) => setState(() => track = value),
                        ),
                      ),
                  ],
                ),
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(
                  en
                      ? 'Filters & learning tools'
                      : 'စစ်ထုတ်ရန်နှင့် လေ့ကျင့်ခန်းများ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                children: [
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
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(courseLevel(v, en)),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => level = v ?? 'all'),
                  ),
                  const SizedBox(height: 10),
                  widget.actions,
                  const SizedBox(height: 10),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      en
                          ? '${visible.length} lessons shown'
                          : 'သင်ခန်းစာ ${visible.length} ခု တွေ့သည်',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  FilterChip(
                    label: Text(en ? 'Not completed' : 'မပြီးသေး'),
                    selected: unfinished,
                    onSelected: (v) => setState(() => unfinished = v),
                  ),
                ],
              ),
              if (visible.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    en
                        ? 'No lessons match these filters.'
                        : 'ရှာဖွေမှုနှင့် ကိုက်သောသင်ခန်းစာ မရှိပါ။',
                  ),
                ),
            ],
          );
        final lesson = visible[index - 1];
        final done = widget.completed.contains(lesson.id);
        return Card(
          child: ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Icon(
                done ? Icons.check : trackIcon(lesson.track),
                size: 21,
                color: scheme.onPrimaryContainer,
              ),
            ),
            title: Text(
              en ? lesson.titleEn : lesson.titleMy,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                '${lesson.id.toUpperCase()} · ${trackLabel(lesson.track, en)} · ${courseLevel(lesson.level, en)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, size: 20),
            onTap: () => widget.onLesson(lesson),
          ),
        );
      },
    );
  }
}
