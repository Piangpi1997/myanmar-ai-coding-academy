# Academy 0.7.0 — 120 lessons and a clearer workspace

The 40 existing Python lessons and their IDs remain unchanged. This update adds 80 authored Myanmar/English lessons, with concept explanations, example walkthroughs, mistakes, practice tasks, sample answers, references and one public self-check question per lesson.

| Subject | Lessons | Practice environment |
| --- | ---: | --- |
| Python | 40 | Existing Python editor; remote execution needs configured services |
| Programming foundations | 20 | Python, Git, SQL and protocol-reading exercises |
| Web development | 20 | Offline HTML/CSS/JavaScript viewer |
| Linux and Kali | 20 | Owned computer/VM lab; no embedded Kali runtime |
| Ethical security | 20 | Defensive examples, fictional data and authorized local labs |
| Total | 120 | Offline reading available without login |

New content is canonical in `content/academy_extensions.json`. Run `python scripts/build-academy-catalog.py` to compile the Dart bundle and migration 008; `--check` detects drift. Existing migrations 001–007 are preserved. Review and apply additive migration `008_academy_tracks.sql` after the existing migrations to synchronize completion for the new IDs. No live migration was applied by this update.

Home groups five subjects and provides direct practice shortcuts. The library combines search, a subject strip, completion filtering and collapsible level/tools controls. Profile puts account details behind an expander. Dark/light themes use quieter surfaces and a shared teal accent. Myanmar remains the initial language and the language preference remains persistent.

Q&A Practice supports 5/10/20 randomly selected unique questions, a question-only preview, answer selection, submission, scoring and per-question explanations. Results use the new account/guest-scoped `practice_tests.v1.<scope>` key with bounded history. Unreadable history is preserved rather than silently overwritten. This is a public self-check, not a certification exam; it does not mark lessons mastered or complete automatically.

The HTML Viewer keeps the existing encrypted `web.v1.<scope>` drafts. It adds clipboard paste, lesson example import with explicit replacement approval, saving and full-screen preview. Imported HTML replaces HTML/CSS/JS only after approval; cancelling leaves the draft intact. The actual preview still uses the restricted Android WebView and opaque sandbox document; network, files, cookies, native APIs, popups and external navigation remain blocked. Full-screen preview is invalidated after an account change. HTML/CSS/JS source is preserved; interactive page state is not promised to persist.

Programming and Linux examples identify their environment. Shell/SQL examples are copied for a computer lab, not sent to the Python runner. HTML lesson examples open the viewer; Python examples use the existing draft replacement workflow. Kali/Nmap practice is scoped to owned loopback/isolated labs. The app does not execute shell commands or scan networks.

Validation on 2026-10-24: 221 backend/content tests passed locally, including trusted Python teaching snippets and non-executing shell syntax checks. Both catalog compilers, dependency consistency and Dart formatting were checked. Flutter analysis/tests, generated mobile UI previews, real Chromium checks of the 40 authored HTML examples/solutions and Android compilation are CI gates. Their exact results and matching debug artifact are recorded on PR #1 and its latest Actions run. Live BYOK, Supabase/RLS/runner integration and physical-device notification/WebView checks remain environment-dependent and are not certified by unit tests.
