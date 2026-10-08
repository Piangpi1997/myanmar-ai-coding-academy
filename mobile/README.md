# Myanmar AI Coding Academy — Flutter starter

This directory contains the first **working-source starter**, not a complete Android app or APK.

## Included

- Material 3 premium-style dark interface
- Five navigation screens: Home, Learn, Code Lab, AI Tutor, Profile
- 10 original short Myanmar beginner Python lessons with examples and exercises
- Lesson completion saved locally using shared_preferences
- Basic Myanmar/English interface labels (lesson content remains Myanmar-first)
- Explicit "planned" notices for unimplemented remote coding and AI chat

## Prerequisites

- Flutter stable SDK installed and accessible on PATH
- Android SDK, Android Studio or a compatible device/emulator
- A correctly configured Android toolchain (`flutter doctor`)

## First-time setup

The generated GitHub source deliberately omits Flutter-generated Android platform boilerplate. Generate it locally with the Flutter CLI:

```bash
cd mobile
flutter create . --project-name myanmar_ai_coding_academy --platforms android
flutter pub get
flutter test
flutter run
```

Run on an Android device or emulator. `flutter create` will generate the `android/` folder and platform metadata; commit them after verifying the generated application identifier and signing setup.

## Important implementation status

| Feature | Current status |
|---|---|
| Navigation / dark UI | Source implemented; device validation pending |
| Myanmar lessons | 10 original introductory lessons included |
| Progress persistence | Local shared_preferences implementation |
| English UI | Partial label translation |
| Login / Supabase | Not implemented |
| AI API chat | Not implemented |
| Code execution and live preview | Not implemented |
| Quiz auto-grading | Not implemented |
| Push reminders | Not implemented |
| Admin CMS | Not implemented |
| Android APK | Not built |

This starter does not pretend to execute Python or produce AI-generated responses. Do not place API secrets in Flutter code.

## Next steps

1. Verify `flutter analyze`, `flutter test`, and `flutter run` on a configured Flutter SDK.
2. Build FastAPI backend and database migrations.
3. Connect Supabase Auth and persisted course progress.
4. Implement secured sandbox runner, then AI chat proxy.
5. Add exercises, accessibility improvements, notifications, and admin CMS.

See [development roadmap](../docs/DEVELOPMENT_ROADMAP.md) and [master prompt](../prompts/FINAL_MASTER_PROMPT.md).

## Supabase Auth + cloud sync configuration (Phase 1 extension)

Backend and SQL migration now exist in `../backend/` and `../database/migrations/`. Execute the SQL migration and configure the backend before using cloud sync.

To run on an Android emulator (host machine FastAPI on port 8000), supply public Supabase configuration and backend origin:

```bash
flutter run --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLISHABLE_KEY --dart-define=BACKEND_URL=http://10.0.2.2:8000
```

For physical Android devices use your machine's reachable LAN IP and allow development traffic only as needed. **Production must use HTTPS**, and Android network-security policy must explicitly control allowed origins. Supabase publishable keys are public identifiers, **not** secret service-role keys; never ship secret keys in mobile binaries.

When Supabase is configured, Profile displays Sign in / Sign up. Signed-in user progress syncs with the backend; guest completion is kept separate. This is an early proof-of-architecture, **not yet an offline conflict-resolution engine**. Email verification may be required depending on your Supabase Auth settings.

At present the starter has no complete automated end-to-end auth verification and no pre-generated APK. Run `flutter analyze`, `flutter test`, device smoke tests, and the backend's `pytest` suite in your configured development environment.
