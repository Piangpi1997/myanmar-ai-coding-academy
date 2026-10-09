# BYOK foundation milestone

Base: `main` commit `3b31c82a3c35dc10fb15109c2b119c2efa6d7767`.
Development branch: `development/byok-foundation`.

This milestone continues the existing Flutter, FastAPI and SQL foundation. It preserves the ten short starter lessons, guest completion data, existing user completion keys, repository identity and original prompt package. It does not claim the full academy specification is finished.

## Implemented source

- Supabase email sign-in/registration, confirmation handling, password recovery callback, session restoration and PKCE verifiers in encrypted local storage, removal of this project's legacy plaintext session, restricted recovery callback and local sign-out.
- Authentication-state listener updates the active account; guest and every account use separate progress, code draft, BYOK settings and chat-history namespaces.
- Serialized progress persistence merges only the same user's local/cloud completions. Offline completions remain local and retry on explicit sync or app resume. A generation guard discards results from a previous account. Guest data is never silently imported into an account.
- BYOK settings with four fixed providers, editable model ID, obscured key, explicit data-sharing notice, encrypted storage and removal. No key is embedded at build time.
- Authenticated backend tutor proxy, seven study modes, Myanmar/English responses, bounded history, per-process quotas, sanitized errors and fixed HTTPS credential destinations.
- Mobile Markdown chat with local account-scoped encrypted history, copy, explicit retry, clearing history and opening Python blocks in Code Lab. Responses are non-streaming in this milestone.
- Python editor with logical line numbers, simple token highlighting, indentation, font size, stdin, account-scoped saved drafts, sample/reset, run and error/output panels.
- Backend Judge0 adapter enforces requested resource/network limits and returns decoded actual results. It fails closed until the operator verifies runner isolation.
- Generated Flutter localization from bilingual ARB resources for authentication, BYOK, tutor, code lab and error states; bundled Noto Sans Myanmar with its OFL license. Existing introductory lesson bodies remain Myanmar-first.
- Light/dark selection and persisted language settings; original home/catalog remain available.
- Profile-creation migration with scoped database grants; no BYOK credentials in SQL.

## Changed source areas

`backend/app/{main,auth,config,limits,ai,runner,upstream}.py`, backend tests/setup/lock file; `mobile/lib/{main,auth_page,cloud_service}.dart`, `mobile/lib/core/`, `mobile/lib/features/{ai,code}/`, ARB localization, fonts, tests and Android platform configuration; `database/migrations/002_profile_lifecycle.sql`; CI and documentation.

## Deployment configuration

Backend: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_JWT_AUDIENCE`; optional `ALLOWED_ORIGINS`; `JUDGE0_URL`, `JUDGE0_AUTH_TOKEN`, `JUDGE0_PYTHON_ID`, `JUDGE0_SANDBOX_VERIFIED` for execution. Never set user BYOK keys as shared backend environment variables.

Android: public `SUPABASE_URL`, public `SUPABASE_ANON_KEY`, HTTPS `BACKEND_URL`. Keep private signing material out of source control. Add `com.piangpi.myanmaracademy://auth-callback` to the intended Supabase project's allowed redirect URLs for verification/password recovery. Users with old starter sessions may need to sign in again when moving to encrypted session storage; learning progress data is retained.

## Live integration checklist (pending)

1. Apply numbered migrations to the intended Supabase project. Use two separate test accounts to verify RLS directly through PostgREST.
2. Register/verify email; restart the app; reset password through the Android deep link; sign out and switch accounts while sync is delayed.
3. Record a completion offline, reconnect and sync; verify it persists without importing guest history.
4. Deploy the API behind HTTPS with no request/header logging and one worker. Configure a shared quota store before scaling replicas.
5. Enter a user-owned provider key on the phone, choose an available compatible model, send a small question, confirm Myanmar output and provider billing. Test key deletion and an invalid key. Never paste a key into GitHub/chat.
6. Deploy and independently audit the runner before enabling it. Verify Hello World, syntax errors, stdin, timeout, memory/output cap, blocked network and isolated filesystem on the real worker.
7. Build/install a debug APK and verify secure-storage, Unicode, keyboard/editor usability, layout at large text sizes, lifecycle and recovery on a physical Android device.

## Known limitations and next milestone

No live provider, Supabase project or runner credentials were supplied. SQL policies and sandbox isolation need real-environment validation. Local chat and code drafts do not sync to cloud. Streaming, custom provider URLs, native Gemini/Anthropic protocols, HTML/CSS/JS preview, hidden-test grading, quizzes, reminders, admin CMS, full English lesson translations, comprehensive 100-lesson curriculum and production signing remain separate milestones. The existing ten lessons are short introductions, not fully reviewed professional courses. Completion is learner-marked, not a mastery certificate.

Next milestone: validate the real Supabase + BYOK + runner workflow on an Android device; then add isolated web preview and graded beginner exercises with server-held tests.

See the validation report for actual executed checks and APK status.
