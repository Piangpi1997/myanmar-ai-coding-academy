# Guest BYOK and beginner-learning update — 0.3.0+3

## Repaired behavior

The original milestone disabled the AI composer and provider route when Supabase was unconfigured or the learner was a guest. A default debug APK therefore displayed an AI screen that could not accept a question. Guests can now type immediately, open the visible **AI provider** button, and save a user-owned key. A request without a saved provider displays guidance and preserves the typed question.

**Direct to provider** is the default for newly saved settings. It needs internet access, a valid user-owned API key, and a compatible Chat Completions model. Supabase and an academy backend are optional for this mode. The four supported fixed HTTPS destinations are OpenRouter, DeepSeek, Groq and OpenAI. Keys, prompts and code are sent to the selected provider only after explicit model loading or sending. Model discovery loads actual model IDs from that provider; users may enter an ID manually. A returned model ID does not guarantee chat capability, sufficient credit or account access.

Guest and account credentials/history are separate encrypted namespaces. Signing in does not import a guest key, chat or learning record. Existing account configs without a transport field retain the authenticated backend route. Account users can choose a configured HTTPS academy backend for tutoring; model IDs are entered manually in that route. No provider key is bundled in Dart defines, source or APK, and keys are not put in the database. Deleting a local key does not revoke it with its provider.

Direct mode is an explicit BYOK usability choice for this user request. It differs from the original master specification's backend-only gateway. User-owned credentials are held in Android secure storage and transient request headers. Server-owned secrets must still stay on the server. Direct mode's 10-attempt/minute device throttle and 1,024-output-token cap are convenience limits, not centrally enforceable academy quotas. Provider billing, data-retention policies and provider quotas apply. There is no automatic paid retry. Responses are bounded, sanitized, non-streaming and never described as actual Python execution.

The composer adapts to a short keyboard viewport; the app hides top/bottom navigation while the keyboard is open. Sending code from Code Lab selects Explain mode and provides a localized starter question. Failures leave an explicit retry action rather than a made-up answer.

## Lesson improvements

All ten original IDs are retained. Twelve shipped beginner lessons now contain original Myanmar and English instruction, objectives, line-by-line notes, common mistakes, hints, an editable practice workflow, complete sample solutions, official Python references and one public self-check question per lesson. Dictionaries (`py-11`) and Error Handling (`py-12`) are new. These are beginner lessons, not a claim of a complete 100-lesson or 1,000-page curriculum. Technical/editorial review by a Myanmar educator remains desirable.

Self-check questions provide immediate right/wrong explanations and store attempts on this device separately for each account and guest. They are public learning questions, not private server-side grading or certificates. Quiz history does not sync to cloud. Lesson completion retains the existing local/cloud synchronization behavior.

Apply `database/migrations/003_beginner_lesson_ids.sql` after 001 and 002 before syncing the two new lesson IDs. It only adds the IDs and preserves existing progress; no live migration was applied here.

## Android Studio and Windows

See [mobile setup](../mobile/README.md). Open the `mobile/` folder as the Flutter project, not just `mobile/android/`. With Flutter/Dart plugins, Flutter 3.35.7, JDK 17 and the Android SDK installed, run `lib/main.dart` on an Android device. No build-time Supabase/backend configuration is necessary for guest lessons, quizzes, local drafts or direct BYOK tutoring. AI requests still require the user's own provider key and internet.

The PowerShell helper runs dependency setup, localization, analysis and tests before run/build:

```powershell
# From the repository root
.\scripts\run-android.ps1 -DeviceId 'YOUR_ANDROID_DEVICE_ID'
.\scripts\run-android.ps1 -BuildApk
```

This helper is source-reviewed, not executed on Windows in this environment. It does not install SDKs, modify PATH or regenerate Android files. If PowerShell execution policy blocks local scripts, use the individual Flutter commands in the mobile README according to your machine's policy.

## Remaining integrations

Cloud auth/progress needs the configured Supabase project and HTTPS FastAPI backend. Actual Python Run still requires authenticated remote sandbox execution; it is not simulated or moved into the app/server process. A verified Judge0 deployment, live provider/device tests, release signing, isolated web preview, hidden-test grading, reminders, projects and admin CMS remain pending.

Next milestone: install this debug build on the target Android phone, validate a real user-owned provider/model and secure-storage lifecycle, then configure Supabase/HTTPS backend and verify two-account progress plus actual sandbox Python execution. Expand beyond the beginner module only after those workflows work.
