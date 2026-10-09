# Myanmar AI Coding Academy — Android development

Flutter 3.35.7 / Dart 3.9.2. The existing ten introductory Myanmar lessons are preserved. The app supports guest reading, separate account progress, Supabase email authentication, a Python editor/remote runner and a BYOK AI Tutor. See [milestone scope](../docs/BYOK_MILESTONE.md) and [actual validation](../docs/VALIDATION_REPORT.md).

## Setup

Android platform files were generated with the official Flutter CLI. Do not regenerate over the configured application ID: `com.piangpi.myanmaracademy` (minimum Android API 23).

```bash
cd mobile
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter run
```

Without configuration the app provides guest lessons and local drafts; remote features require a signed-in account and a configured backend. Apply the SQL migrations and follow [backend setup](../backend/README.md), then run with **public** build configuration:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_PUBLISHABLE_KEY \
  --dart-define=BACKEND_URL=https://YOUR_BACKEND_HOST
```

All API origins must use HTTPS. Do not put service-role, AI or Judge0 secrets in Dart defines. Add `com.piangpi.myanmaracademy://auth-callback` to Supabase's allowed redirect URLs. Use an asymmetric Supabase JWT signing key (RS256/ES256); legacy HS256 is unsupported by this backend.

## BYOK

Sign in, open Profile → BYOK settings, select OpenRouter, DeepSeek, Groq or OpenAI, enter an available Chat Completions model ID and your own key, review the sharing/billing notice and save. Each account has encrypted credentials and chat history. Keys are sent only when explicitly asking AI, through your HTTPS backend to the selected fixed provider endpoint. Removing a key prevents subsequent requests; it does not revoke it at the provider. Chat history can be cleared in the tutor.

The tutor supports Ask, Explain, Debug, Practice, Review, Mentor and Project modes. Output is Markdown with copy and Python insertion. Responses are non-streaming and are predictions unless code is separately run in the Code Lab. No automatic paid retry occurs.

## Builds and signing

Install Android SDK/platforms and JDK 17; confirm the Android toolchain with `flutter doctor -v`.

```bash
flutter build apk --debug
```

Use the same public Dart defines above to connect the APK to deployed services. CI's default debug APK is a guest-mode build.

Release builds require your own keystore and ignored `android/key.properties`:

```properties
storeFile=/absolute/path/to/your-release.keystore
storePassword=YOUR_LOCAL_PASSWORD
keyAlias=YOUR_ALIAS
keyPassword=YOUR_LOCAL_PASSWORD
```

```bash
flutter build apk --release
```

Missing release signing configuration fails the build; release does not silently use debug signing. Never commit this file or the keystore. No release signing credentials are included.

## Scope and device checks

Generated ARB localization covers auth, tutor, BYOK, editor and errors; the existing home/catalog retain bilingual labels and lesson bodies remain Myanmar-first. Noto Sans Myanmar regular font is bundled under OFL in `assets/fonts/`.

Before release, validate two-account sync, verification/recovery links, session restoration, Unicode, keyboard/editor behavior, secure storage and layouts on physical Android devices. Web preview, grading, reminders, expanded curriculum and administration are still pending. See the [roadmap](../docs/DEVELOPMENT_ROADMAP.md).
