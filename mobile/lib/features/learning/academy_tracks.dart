import 'package:flutter/material.dart';

const academyTracks = ['python', 'programming', 'web', 'linux', 'security'];
String trackLabel(String track, bool en) => switch (track) {
  'python' => 'Python',
  'programming' => en ? 'Programming' : 'Programming အခြေခံ',
  'web' => en ? 'Web development' : 'Web တည်ဆောက်ခြင်း',
  'linux' => en ? 'Linux & Kali' : 'Linux နှင့် Kali',
  'security' => en ? 'Ethical security' : 'လုံခြုံရေး လေ့လာခြင်း',
  _ => en ? 'All subjects' : 'ဘာသာရပ်အားလုံး',
};
IconData trackIcon(String track) => switch (track) {
  'python' => Icons.code_rounded,
  'programming' => Icons.account_tree_outlined,
  'web' => Icons.web_outlined,
  'linux' => Icons.terminal_rounded,
  'security' => Icons.shield_outlined,
  _ => Icons.menu_book_outlined,
};
