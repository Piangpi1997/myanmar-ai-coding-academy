# Myanmar AI Coding Academy — Android development

Flutter 3.35.7 / Dart 3.9.2. The original ten IDs are preserved and expanded; twelve beginner lessons now have Myanmar/English instruction, hints, solutions and local quizzes. The app supports guest reading, separate account progress, Supabase email authentication, a Python editor/remote runner and a BYOK AI Tutor. See [milestone scope](../docs/BYOK_MILESTONE.md) and [actual validation](../docs/VALIDATION_REPORT.md).

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

Without build configuration the app provides guest lessons, quizzes, local drafts and direct BYOK AI tutoring with your own provider key. Cloud progress/auth and remote Python execution require configured services. Apply the SQL migrations and follow [backend setup](../backend/README.md), then run with **public** build configuration:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://YOUR_PROJECT.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=YOUR_PUBLIC_PUBLISHABLE_KEY \
  --dart-define=BACKEND_URL=https://YOUR_BACKEND_HOST
```

All API origins must use HTTPS. Do not put service-role, AI or Judge0 secrets in Dart defines. Add `com.piangpi.myanmaracademy://auth-callback` to Supabase's allowed redirect URLs. Use an asymmetric Supabase JWT signing key (RS256/ES256); legacy HS256 is unsupported by this backend.

## Learning workspace

Learn now links to seven pathways, six Python challenges and sixteen project guides. Drafts, selected paths, project checkpoints and notes are account/guest scoped; guest use is local/offline. Account users can read server assessment history. See [learning workspace](../docs/LEARNING_WORKSPACE.md) for actual scope, privacy, assessment setup and limitations. Project checkboxes are self-reported, not server certificates. Actual Python running/grading still requires configured services.

## Run from Android Studio on Windows

1. Fetch and switch to `development/byok-foundation`; preserve or commit your own local edits before switching.
2. Install the Flutter and Dart plugins. Open **the repository's `mobile` folder**, which contains `pubspec.yaml`. Opening only `android` gives a Gradle project rather than the Flutter run configuration.
3. Set the Flutter SDK path to your Flutter 3.35.7 folder under Settings → Languages & Frameworks → Flutter.
4. Use Android SDK Manager to install **Android SDK Command-line Tools (latest)**, platform API 36, Build Tools 35.0.0 and NDK 27.0.12077973. Match SDK Location to Flutter's configuration.
5. Use JDK 17 for Flutter/Gradle. For the reported installation, run:

```powershell
flutter config --jdk-dir 'C:\Program Files\Eclipse Adoptium\jdk-17.0.20.101-hotspot'
flutter config --android-sdk "$env:LOCALAPPDATA\Android\Sdk" # use actual Studio SDK Location if different
flutter doctor --android-licenses
flutter doctor -v
```

6. In Studio's terminal inside `mobile`, run `flutter pub get` and `flutter gen-l10n`. The repository includes a portable `main.dart` Flutter Run configuration. Open `lib/main.dart`, select the connected Android device, and use Run (or right-click `main.dart` → Run). If the toolbar has no Flutter configuration, create a Flutter Run configuration whose Dart entrypoint is `lib/main.dart`. Leave additional arguments empty for guest/direct BYOK.

Visual Studio's Windows desktop warning does not block Android builds. Android command-line tools are required; installing Android Studio alone does not guarantee they are present. Never regenerate this repository with `flutter create .` just to fix missing SDK tools.

```powershell
# Repository root, optional checked run/build helper
.\scripts\run-android.ps1 -DeviceId 'YOUR_ANDROID_DEVICE_ID'
.\scripts\run-android.ps1 -BuildApk
```

Debug APK location: `mobile/build/app/outputs/flutter-apk/app-debug.apk`.

## BYOK

Open AI Tutor → AI provider (or Profile → BYOK settings), select **Direct to provider**, choose OpenRouter, DeepSeek, Groq or OpenAI, enter your own key, and accept the sharing/billing notice. Tap **Load available models**, select a compatible Chat Completions model, then **Save**. Manual model entry is also supported. Return to Tutor, type a question and tap Send. No login is required for guest direct BYOK. Each account and guest has separate encrypted credentials and chat history. Keys are sent only on explicit model loading or a question, to the fixed provider HTTPS endpoint. Account users may choose the configured academy backend; old account settings retain that route. Removing a key prevents subsequent requests; it does not revoke it at the provider. Chat history can be cleared in the tutor.

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

Before release, validate two-account sync, verification/recovery links, session restoration, Unicode, keyboard/editor behavior, secure storage and layouts on physical Android devices. Web preview, hidden-test grading, reminders, curriculum beyond the beginner module and administration are still pending. See the [roadmap](../docs/DEVELOPMENT_ROADMAP.md).
