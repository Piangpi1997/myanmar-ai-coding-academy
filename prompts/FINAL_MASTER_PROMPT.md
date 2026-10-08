# MYANMAR AI CODING ACADEMY — FINAL MASTER APP BUILDER PROMPT

## ROLE AND OBJECTIVE
You are an expert product team: Android engineer, Flutter architect, Python backend engineer, AI integration specialist, Burmese-language educator, curriculum designer, senior UI/UX designer, security engineer and QA lead.

Build **Myanmar AI Coding Academy — Zero to Hero**, a premium Android education application that teaches complete beginners programming in Myanmar (Burmese), with English as an additional UI/teaching language. The learner must study a concept, inspect illustrated explanations, write real code, run it, view actual output, solve exercises, receive feedback, and ask an AI tutor contextual questions—all in one coherent workflow. Deliver working functionality, not just a static mockup. Do not claim unfinished features are working.

Tagline: **Learn Coding in Myanmar — From Absolute Beginner to Professional Developer.**

## PLATFORM, STACK, AND ARCHITECTURE
- Primary platform: Android smartphones/tablets; Flutter + Dart, Material Design 3, responsive layouts.
- State and routing: Riverpod + GoRouter (or well-justified equivalents).
- Backend: Python FastAPI with typed schemas, tests, structured errors and OpenAPI documentation.
- Database and authentication: PostgreSQL, Supabase Auth, Row-Level Security, Supabase Storage.
- Admin CMS: responsive Next.js/React web application, role-based permissions.
- AI tutor: configurable OpenAI-compatible model API through a secure server-side gateway, never direct secret-bearing mobile calls.
- Remote code runner: sandboxed Judge0-compatible execution service behind an authenticated backend; no execution of untrusted code in the API server.
- HTML/CSS/JS live preview: properly isolated WebView with safe-origin rules and no privileged Android bridge exposed to user JS.
- Notifications: Firebase Cloud Messaging and Android local scheduling, time-zone-aware user preferences.
- Offline: local cache/download of approved lessons and notes; Drift/SQLite as appropriate.
- Ship Android source, backend source, admin source, migrations, test suites, sample data, setup guides, deployment instructions and an Android build procedure.
- If the current app builder cannot generate native Flutter or a particular integration, build the closest functional supported equivalent, explicitly label limitations, and provide a migration path. Do not fabricate support.

## PREMIUM PRODUCT DESIGN
Deliver professional, visually rich and accessible UI, not generic templates. Palette: background #080D1B, surface #111B2E, purple #775CFF, cyan #00D9E8, success #27D9A0, warning #FFBE55, text #F5F7FF, muted #98A6C1. Premium dark/light modes; polished illustrated course cards; responsive layout; progress rings; refined spacing; subtle transitions; skeleton loaders; error/empty/success states; tactile touch targets; modern charts and badges. Use licensed/original assets. Fonts: Noto Sans Myanmar for proper Unicode rendering, Inter for Latin UI, JetBrains Mono for coding. All typography must correctly display Myanmar Unicode and remain readable on small Android phones. Accessibility: contrast, large text support, screen reader labels and reduced motion.

Navigation tabs: **Home | Learn | Code Lab | AI Tutor | Profile**. Screens: onboarding, sign-up/sign-in, catalog, roadmap, course details, lesson reader, interactive exercise, quizzes, challenge results, project workshop, bookmarks, downloaded materials, notifications, learning stats, achievements, certificates, settings and search. Ensure screen-to-screen navigation is operational.

## MYANMAR-FIRST LANGUAGE SYSTEM
Myanmar is the default instruction language. Full English/Myanmar localization for UI, notifications, course labels, lesson text and AI response choices. Preserve programming keywords and code in English; explain technical vocabulary in Burmese and show English equivalent terms. Store localized strings and lesson translations separately. AI defaults to clear conversational Myanmar, adapting difficulty to user's level. Support Myanmar-language searches, input and natural follow-up questions. Technical translations should pass expert editorial review.

Example lesson interaction:
- Heading: “Variable ဆိုတာဘာလဲ?”
- Explain in simple Burmese that variables name and store values.
- Show code:
```python
name = "Aung Aung"
age = 20
print(name)
print(age)
```
- Explain each line in Myanmar, show actual output from the runner, ask one question, provide an editable exercise, evaluate it, then offer contextual AI help.

## COMPREHENSIVE ZERO-TO-HERO CURRICULUM
Plan an **original instructional corpus comparable in depth to approximately 1,000–1,500 textbook pages** across modular, searchable lessons, progressively from absolute beginner to advanced, professional practice. This is a content roadmap and quality target; distinguish complete lessons from outlines and drafts. Prioritize genuinely comprehensive teaching over bulk filler. Organize into prerequisite-gated beginner, intermediate, advanced and professional levels.

TRACK A — Computer & coding foundations: hardware/software, operating systems, files/folders, internet, algorithms, terminal basics, editors, debugging mindset, syntax concepts, development workflows and programming terminology.

TRACK B — Python Zero to Hero (100+ planned comprehensive lessons): installation; print; variables; types; strings; operators; input; conditions; loops; collections; slicing; functions; scope; modules; packages; exceptions; files; JSON; standard library; datetime; regex; comprehensions; iterators; generators; decorators; context managers; virtual environments; pip; type hints; dataclasses; OOP; testing; logging; debugging; async; concurrency; HTTP; APIs; SQLite/PostgreSQL; automation; NumPy/Pandas; web scraping ethics; FastAPI; authentication; security; deployment; maintainability; optimization; professional portfolio.

TRACK C — Web: semantic HTML, forms, accessibility, CSS flexbox/grid/responsiveness/animations, modern JavaScript, DOM, async/await, fetch, TypeScript, React, components, app state, APIs, testing and deployment.

TRACK D — Databases: SQL, relational models, joins, indexes, transactions, PostgreSQL, schema migrations, query optimization, integrity, access controls and backups.

TRACK E — Backend & APIs: HTTP, REST, JSON, FastAPI, validation, JWT, OAuth concepts, secure auth, RBAC, rate limits, testing, observability, Docker and deployment.

TRACK F — Android/Mobile: Dart, Flutter widgets/layout, state, navigation, forms, network, storage, Firebase, notifications, offline-first design, Android packaging and app publishing.

TRACK G — AI/ML: AI concepts, Python data tooling, ML workflow, model evaluation, neural nets, LLMs, prompt engineering, embeddings, retrieval-augmented generation, AI APIs, chatbots, responsible AI and production integration.

TRACK H — Professional engineering: Git/GitHub, branching, PRs/reviews, data structures, algorithms, Big-O, tests, clean code, architecture, secure coding, Linux, CI/CD, Docker/cloud, team collaboration, documentation, interviews and portfolio projects.

Inform the writing with well-established principles from official Python, JavaScript, Flutter, PostgreSQL and Git documentation, and reputable books including Python Crash Course (Eric Matthes), Automate the Boring Stuff with Python (Al Sweigart), Fluent Python (Luciano Ramalho), Effective Python (Brett Slatkin), Clean Code (Robert C. Martin), Introduction to Algorithms (Cormen et al.) and Eloquent JavaScript (Marijn Haverbeke). **Respect copyrights**: create original teaching text, code samples, figures and exercises; do not reproduce significant protected book content without a license. Include citations/links for referenced sources where appropriate.

## EVERY LESSON MUST INCLUDE
A stable lesson ID and localized title; prerequisites; learning objectives; estimated duration; clear Burmese conceptual explanation; real-life analogy; original diagram/illustration; syntax and runnable examples; line-by-line explanation; expected output; common errors; guided tutorial; practical coding activity; at least five review/practice questions; quiz with explanation; hints; challenge tests; recap; flashcards; supplemental resources; contextual AI chat entry points; persistent completion criteria. Include initial code, sample inputs, visible tests, protected hidden tests, verified reference answer, and understandable Myanmar feedback for graded exercises. Support retries and accessible alternate explanations.

## AI CODING TUTOR (REAL FRONTEND + API)
Chat UI with streamed responses, Markdown, code highlighting, copy, insert into editor, saved chat history and active lesson context. Modes: Explain, Debug, Practice, Review, Quiz, Project and Mentor. Functions: answer Myanmar programming questions; explain snippets line by line; diagnose actual compiler/runtime errors; review code against quality criteria; generate graded hints; tailor difficulty; build a realistic personalized roadmap; generate study questions; support follow-up context; cite lesson materials. Favor progressive hints before full answer for assessments. Clearly distinguish predicted from actually executed outputs.

Backend endpoints (adapt as needed):
POST /api/ai/chat
POST /api/ai/explain
POST /api/ai/debug
POST /api/ai/review
POST /api/ai/generate-quiz
POST /api/ai/study-plan
GET /api/ai/history
DELETE /api/ai/history/{id}

Use authenticated backend, validated inputs, model/provider configuration, streaming where supported, usage quotas, rate limiting, safeguards against malicious prompt content, monitoring and cost ceilings. **Never embed AI credentials in APK or frontend**. Respect learner privacy, support data deletion and clear retention policies. Handle timeouts/provider unavailability gracefully.

## REAL MOBILE CODE LAB
An ergonomic in-app IDE with line numbers, syntax highlighting, monospaced font, auto-indent, bracket pairing, optional completion/snippets, editor keyboard toolbar, project/file tabs, undo/redo, search/replace, save/open/rename/delete, autosave, file browser and theme choice. Actions: **Run | Preview | Save | Reset | Ask AI**. Support Python first, then JavaScript, HTML/CSS, SQL and additional runtimes as integration permits.

Code execution: Android client → authenticated backend → segregated sandbox worker → genuine stdout/stderr/exit code/results returned to UI. Enforce CPU, memory, disk, time and output limits, network restrictions, per-user rate limits, controlled dependencies and isolated ephemeral filesystems. Never simulate successful execution. Support stdin when appropriate and display syntax/runtime/timeout errors. For HTML/CSS/JS, combine project files in an appropriately sandboxed preview with responsive viewport options; deny untrusted scripts access to app session/authentication and native APIs. For Python, distinguish console output and generated supported artifacts from unsupported desktop GUI previews.

## PRACTICE, QUIZZES & PROJECTS
Exercise modes: MCQ; fix bugs; predict output; fill blanks; arrange code; write function; implement a specification; code review; integrated project. Execute and grade code on isolated runners against visible and server-held hidden tests. Show accurate pass/fail feedback and Myanmar explanations; never leak hidden answers in client payloads.

Beginner projects: calculator, converter, guessing game, to-do list, quiz app, password generator. Intermediate: file organizer, weather API client, expense tracker, SQLite app, portfolio site, CRUD API, beginner chatbot. Advanced: full-stack ecommerce demo, secure FastAPI backend, Flutter app, AI study assistant, analytics pipeline. Each includes a goal, design, requirements, file structure, guided tutorial, actual working code, checks/tests, common errors and deployment/portfolio notes. GitHub export may be added only with a legitimate user-authorized integration.

## PERSONALISED ROADMAP, GAMIFICATION & LEARNING DATA
Onboarding asks level, interests, career direction, preferred language and available study time. Paths: Complete Beginner; Python; Web; Backend; Mobile; AI; Full-Stack; Software Engineering. Adapt based on actual assessments, projects and knowledge gaps. Offer realistic milestones without promising guaranteed jobs or expertise in a fixed number of days.

Show daily goals, XP, streaks, badges, weekly challenges, completion graphs, quiz scores, time-on-task, mastery areas, activity calendar, revision recommendations, project showcase and certificates of completion. Progress and mastery must be based on evidence, not just minutes spent.

## REMINDERS AND OFFLINE ACCESS
Users choose reminder time, days, goal, quiet hours and notification opt-out. Send local reminders and permitted push notifications with timezone awareness, Android permission handling and reliable schedules after restarts. Myanmar message samples: “ဒီနေ့ Python Lesson ကို ၁၅ မိနစ် လေ့လာကြရအောင်။” and “Coding Streak ဆက်ထိန်းဖို့ Exercise တစ်ခု လေ့ကျင့်ပါ။” Add scheduled revision reminders and avoid notification spam.

Allow downloading licensed course text, diagrams and notes for offline reading; sync bookmarks and progress when online. Label AI chat, remote code running and cloud sync as online-only where applicable.

## AUTHENTICATION, ACCOUNT AND DATA
Email/password, verification, password recovery, Google sign-in when configured, optional guest view, secure session and sign-out. Profile with username/avatar, proficiency, current path, preferences, saved code, progress, badges and certificates. Provide privacy controls, export and account deletion.

PostgreSQL tables (design sensible keys, indexes, timestamps and referential integrity): users, profiles, user_settings, roles, tracks, courses, modules, lessons, lesson_translations, lesson_assets, source_references, code_examples, exercises, exercise_test_cases, quizzes, questions, answers, enrollments, lesson_progress, exercise_submissions, quiz_attempts, study_sessions, goals, streaks, bookmarks, flashcards, achievements, certificates, coding_projects, project_files, execution_jobs, execution_results, ai_conversations, ai_messages, ai_usage_records, notifications, notification_preferences, content_revisions, content_approvals, audit_logs and app_settings. Separate private and published content. Enable Row-Level Security and server-side authorization checks. Hidden grader tests and privileged keys must never be client-readable.

## ADMIN PANEL & CONTENT CMS
Create responsive secure web admin for roles Administrator, Editor, Educator and Support (least-privilege). Features: analytic overview, student account management, courses/modules CRUD, Burmese/English rich lesson editing, code-block editor and previews, diagram uploads, assessment/test editing, content review→approval→publish states, version history, learning metrics, AI/API cost dashboard, code-runner health, notifications, announcements, settings, audit logs and exportable reporting. No default hardcoded production passwords.

Build a content pipeline: design learning outcomes → draft original lesson → translate/adapt into accurate Myanmar → produce original visuals/examples → validate code automatically → generate/verify quizzes → human educational/technical review → approve/publish → gather feedback and refine. Dashboard must distinguish Planned, Draft, Under Review and Published content. Never mark unwritten lessons as complete.

## SECURITY & PERFORMANCE
HTTPS; secure secrets; mobile token storage; least privilege; per-user ownership controls; RLS; strict server-side validation; abuse/cost quotas; safe uploads; auditability; data minimization; account deletion; code sandbox isolation; bounded CPU/memory/runtime; dependency review; reproducible migrations; privacy-sensitive analytics. Lazy loading, pagination, image compression, resilience to poor connectivity, crash recovery and persistent unsaved-editor drafts. Test rendering on real Myanmar Unicode-capable Android devices.

## TESTING AND ACCEPTANCE
Provide unit tests, Flutter widget/integration tests, backend API tests, database RLS tests, AI-provider mock integration tests, isolated real-runner tests, grading tests, reminder tests, Myanmar/English localization checks, basic accessibility and end-to-end tests. Demonstrate complete journey: Sign up → Choose language/path → Open lesson → Read Myanmar explanation → Edit/Run code → See real output → Submit challenge → Receive result → Ask tutor → Save progress → Configure reminder.

Functional acceptance conditions:
- Real account registration, login, saved progress.
- Native or clearly supported Android deliverable.
- Genuine Myanmar and English UI rendering.
- Readable original lessons and original illustrative assets.
- Authentic Python execution/results in isolated runner.
- Safe, working HTML/CSS/JS visual preview.
- Correct exercise evaluation and protected hidden tests.
- Secure, functioning server-mediated AI tutor.
- Configurable daily reminders.
- Secure course authoring/publishing admin interface.
- Reproducible source, environment templates, tests and deployment/build documentation.

## PHASED EXECUTION AND INITIAL SCOPE
**Phase 1:** Architecture, full premium design system, responsive Android shell, navigation, language switching, auth, schema/migrations, admin login.
**Phase 2:** Course catalog, interactive lesson reading, CMS, structured Python track roadmap, first 10 polished fully authored beginner Python lessons with exercises and two beginner projects.
**Phase 3:** Working editor, actual Python remote code runner, isolated web preview, autograder with protected tests.
**Phase 4:** AI tutor backend gateway, chat streaming, lesson context, explain/debug/review features and usage controls.
**Phase 5:** Personalization, quiz engine, badges, daily reminders, learning analytics, offline lesson reader.
**Phase 6:** Content expansion tooling toward 100+ Python lessons and approximately 1,000–1,500 textbook-page equivalents across all tracks; security audits, testing, deployment and Play Store readiness.

At initial handoff produce:
1. Architecture summary and folder tree.
2. Working Android code and visual design assets.
3. Backend and admin code.
4. SQL migrations, access policies and development seed data.
5. Ten **fully written** Burmese-first Python beginner lessons, graded exercises and two working mini-projects (not placeholder chapter titles).
6. Working code execution and HTML preview where supported.
7. Real authenticated AI tutor integration requiring secure user-supplied deployment credentials.
8. Configurable notifications, saved progress and learning dashboard.
9. Environment `.env.example` containing only placeholders.
10. Setup/build/deployment documentation and honest integration/feature status matrix.
11. Automated tests and a concise report on which tests were actually run.
12. Next-phase curriculum publishing plan, with editorial and copyright checks.

When a builder cannot accomplish the whole application in a single generation, complete the first vertical slice with working state and clear tests, then document the precise next steps. Do not promise, fake or quietly omit functionality. Do not stop after writing an outline or generating screen mockups. Prioritize functional, maintainable code and high-quality Burmese instruction over decorative complexity.

**BEGIN IMPLEMENTATION NOW: produce the architecture, premium Android app foundation, and working end-to-end beginner learning flow first, with real persistent data and validated integrations.**
