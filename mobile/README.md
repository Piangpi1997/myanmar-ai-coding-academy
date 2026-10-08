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
