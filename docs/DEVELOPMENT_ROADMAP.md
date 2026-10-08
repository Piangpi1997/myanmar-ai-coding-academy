# Myanmar AI Coding Academy — Development Roadmap

Status: Planning / Prompt package only. This is not yet an APK or functional app.

## Product goal
Build a Myanmar-first Android app that teaches programming from zero to practical professional skills, with bilingual lessons, hands-on coding, AI assistance, practice, and progress tracking.

## Recommended architecture
- **Android:** Flutter / Dart, Material 3, Riverpod, GoRouter, Noto Sans Myanmar.
- **Backend:** Python FastAPI with typed Pydantic request and response models.
- **Database and authentication:** Supabase (PostgreSQL, Auth, Storage) with Row Level Security.
- **AI tutor:** Backend proxy to an OpenAI-compatible provider; never ship API keys in an APK.
- **Code runner:** Dedicated Judge0-compatible service with sandboxing, quotas and strict execution limits; do not execute learner code inside the primary backend.
- **Web preview:** Isolated HTML/CSS/JS WebView with restricted origin and no privileged bridges.
- **Admin CMS:** Next.js / React, with role-based lesson approval and publishing.
- **Notifications:** Local Android scheduling and optional Firebase Cloud Messaging.

## Milestone 1 — Working Android foundation
- [ ] Create Flutter Android app in `mobile/`.
- [ ] Configure app theme (premium dark and light), Burmese fonts and localization.
- [ ] Build navigable Home / Learn / Code Lab / AI Tutor / Profile screens.
- [ ] Add email sign-in / sign-up using Supabase Auth, with secure persisted sessions.
- [ ] Create basic PostgreSQL schema and migrations for profiles, courses, modules, lessons, enrollments, and progress.
- [ ] Seed one complete Burmese beginner module and 10 reviewed Python lessons.
- [ ] Implement lesson reading and persistent completion tracking.
- [ ] Add loading, offline and error UI states.
- [ ] Run automated tests and document Android build commands.

**Acceptance:** User can register, choose Myanmar, read a real lesson, and resume progress after restarting the app.

## Milestone 2 — Functional Code Lab
- [ ] Mobile-friendly editor with syntax highlighting, saved drafts, and project files.
- [ ] Backend submission endpoint, execution status and stdout/stderr rendering.
- [ ] Isolated sandbox execution with CPU, memory, timeout and output limits.
- [ ] Secure HTML/CSS/JS preview.
- [ ] Test cases for Python exercises and explanatory feedback in Burmese.

**Acceptance:** Hello World prints actual sandbox output; malformed code shows real errors; no test code runs in the FastAPI server process.

## Milestone 3 — AI tutor
- [ ] Server-protected AI configuration and authenticated chat endpoint.
- [ ] Streaming responses, error handling and usage quotas.
- [ ] Myanmar-first explanations with lesson context.
- [ ] Ask / Explain / Debug / Hint workflows and saved conversation history.
- [ ] No fabricated run results; AI labels unverified suggestions.

**Acceptance:** Authenticated learner asks about the current lesson and receives Myanmar explanation without exposing credentials in the app.

## Milestone 4 — Quizzes, reminders, admin and personalization
- [ ] Quiz bank, auto grading, attempt history, and progress dashboard.
- [ ] Daily learning reminders with user-selected schedule and permission handling.
- [ ] Admin CMS with create/edit/review/publish lesson workflows.
- [ ] Personalized learning tracks, project tasks and achievements.
- [ ] Offline reading, account/data deletion and accessibility audit.

## Milestone 5 — Content scale and release
- [ ] Expand through editorially reviewed original lessons equivalent in depth to 1,000+ textbook pages.
- [ ] Credit educational references; avoid copying copyrighted books.
- [ ] Add advanced Python, web, databases, Flutter, AI and software engineering tracks.
- [ ] Perform performance, security and device testing.
- [ ] Set up CI, Android signing, release packaging and privacy documentation.

## Suggested repository structure
```text
mobile/                 # Flutter Android app
backend/                # FastAPI and API tests
admin/                  # Next.js content administration
database/migrations/    # Versioned SQL migrations
content/                # Original lesson authoring and examples
docs/                   # Architecture and development plans
prompts/                # Existing master prompts
.github/workflows/      # CI checks
```

## Initial development conventions
- Protect `main`; use feature branches and reviewed pull requests.
- Add `.env.example` files but NEVER commit real secrets.
- Verify Myanmar Unicode and mobile accessibility early.
- Use real backend/data flows where stated; label mock and placeholder features clearly.
- Prefer reliable working vertical slices over a giant scaffold with nonfunctional buttons.

## Recommended next development task
**Build Milestone 1 as a real Flutter + FastAPI + Supabase foundation.** Deliver tested code and instructions. Do not attempt the full curriculum and all AI features in one implementation step.

Original full product specification: [Master Prompt](../prompts/FINAL_MASTER_PROMPT.md).
