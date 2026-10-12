# Original curriculum and Android Web Lab — 0.5.0+5

This update continues `development/byok-foundation` from `aa3c783e5be768f4c253892f1e0f850f56a35a2d`. It preserves existing lessons, account/guest separation, Supabase authentication, direct BYOK, remote Python grading and project workflows. It is a development build, not the entire master specification or a production certification.

## Shipped learning material

There are **36 original bilingual lessons**, not 100 fabricated titles. The twelve existing lessons remain. Twenty-four new lessons cover tuples, sets, string cleaning, comprehensions, imports, JSON, paths, UTF-8 files, CSV, exception boundaries, objects/composition, virtual environments, regular expressions, SQLite, unit testing, decorators, generators, context managers, type hints, Git, clean functions, secret handling and binary search.

Every lesson includes objectives, original Myanmar/English explanations, an example, line notes, common mistakes, a challenge, hints, a complete sample answer, a quiz with explanatory feedback, a concept flow and a technical reference. New lessons also record prerequisites and whether a computer environment is needed. No AI-generated run result is presented as actual execution. The trusted repository-owned examples and solutions are executed only in bounded child **test** processes; learner submissions still go exclusively to the remote sandbox.

`content/python_course.json` is the new lessons' authoring source. `scripts/build-python-course.py` encodes it into `mobile/lib/generated/python_course.dart` and additive migration `005_python_course.sql`; it does not generate lesson prose. Run it after editing content; CI's `--check` rejects drift. The generated Dart file is deliberately excluded from manual formatting. Foundational lesson text remains in `lessons.dart` / `lesson_guides.dart`; shared types are in `lesson_models.dart`.

Learn lazily builds lesson cards, searches both languages and IDs, filters by course level, and hides completed lessons on request. Paths and relevant project references now include the newly shipped topics. A lesson's computer notice matters: remote Python may not have filesystem access, installed Git, or the required third-party packages. The course does not pretend to include complete FastAPI, PostgreSQL, asyncio, deployment or cloud modules yet. The 1,000-page editorial goal also remains outstanding.

## Functional Android web preview

Open **Code Lab → HTML / CSS / JavaScript lab**. The three tabs are editable without login. A starter template responds to its button using real JavaScript. Live preview reloads after a short edit debounce; Refresh reloads explicitly, and Reset preview recreates the renderer without deleting source. The viewport selector supports fit, 320, 390 and 768 CSS-pixel widths, with horizontal scrolling for wider previews. Console output/errors are bounded and shown as untrusted text. Save and automatic saves use encrypted guest/account-specific storage. Starter replacement asks before overwriting the draft. Unreadable saved data is preserved until it can be recovered.

Sources: `web_project.dart`, `web_lab_page.dart`, and Android `RestrictedPreview.kt`, registered in `MainActivity.kt`. No new runtime package dependency was required.

### Security boundaries

- Flutter creates a disposable native WebView through a platform view. The Flutter/native MethodChannel is **not** a JavaScript bridge and carries no authentication or BYOK data.
- The page embeds learner content in an iframe with **only `allow-scripts`**: no same-origin, popups, forms, downloads or top-navigation permissions. Its opaque origin blocks parent DOM, cookies and local storage.
- The outer/inner content-security policies deny network connections, external assets, nested frames, forms, base URLs and objects. Inline CSS/JavaScript and data images/fonts are permitted for local exercises.
- Native settings independently block network, file/content URLs, mixed content, storage, downloads and navigation. Permissions, file pickers, geolocation and JavaScript dialogs are denied. No `addJavascriptInterface` is installed. Source and document sizes and console messages are bounded.
- Renderer termination handling is included; Android 10+ can terminate an unresponsive renderer. This is a restricted learning preview, not a resource-isolated hostile-code execution service. Older devices and vendor WebViews need device testing, especially for heavy/infinite JavaScript. Remote Python retains its separate verified Judge0 boundary.

References: [Flutter platform views](https://docs.flutter.dev/platform-integration/android/platform-views), [Android WebSettings](https://developer.android.com/reference/android/webkit/WebSettings), [native bridge risks](https://developer.android.com/privacy-and-security/risks/insecure-webview-native-bridges), and [iframe sandbox](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Elements/iframe). Instructional prose and examples are original; references identify concepts, not copied book content.

## Deployment and Android Studio

No new environment variables. Guest lessons, web preview and direct BYOK do not require a backend. Set a provider/key/model in AI Tutor → AI provider, save, then type and send; a real compatible provider key is required for a real response. Cloud authentication/progress and Python running/grading require the existing documented Supabase/backend/verified runner setup. Apply migration **005 after 001–004** before syncing completion of py-13 through py-36. This session did not apply SQL to a live project.

Follow `mobile/README.md`: open **mobile**, install Flutter/Dart plugins, select Flutter 3.35.7, JDK 17 and Android SDK/API 36, install Command-line Tools, accept Android licenses, then run `lib/main.dart`. The portable run configuration and `scripts/run-android.ps1` remain. Production signing is deliberately separate and requires the owner's ignored signing files. CI debug APK signing can differ from a locally installed build; preserve learning data and use your established local signing build when updating it.

## Validation and remaining work

See `VALIDATION_REPORT.md` for commands actually executed. CI additionally exports the **same** preview document with `export-web-preview-fixtures.dart` and runs Chromium assertions in `test-web-preview.cjs`: real starter interaction, parent/storage/cookie boundaries, blocked network, closing-tag escaping, preserved comparison operators, and observable runtime errors. Network routes are aborted if the policy regresses; tests never send fixture data externally. Browser-document checks do not certify Android WebView settings on a physical phone.

Next: expand the remaining original curriculum to at least 100 substantial lessons with meaningful assessments, then add reminders/study analytics and an administrator-protected CMS. Live Supabase/RLS/runner/provider validation, distributed quotas, streaming, release signing, device accessibility/performance and production deployment remain required. No certificates or deployment success are invented.
