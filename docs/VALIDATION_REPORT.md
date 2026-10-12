# BYOK foundation validation — 2026-10-09

Base commit: `3b31c82a3c35dc10fb15109c2b119c2efa6d7767`.
Branch: `development/byok-foundation`. This report describes local checks, not production certification.

## Current update (0.3.0+3)

Base of this update: `5e2c31113f088197fa3f4466657af3b59762ef73`.

| Command actually executed | Result |
|---|---|
| `flutter pub get --offline` | Passed after restoring official SHA256-verified package archives in the local SDK/package cache |
| `flutter gen-l10n` | Passed |
| `dart format mobile/lib mobile/test` | Passed; affected files formatted |
| `flutter analyze --no-pub` | Passed, **no issues found** |
| `flutter test --no-pub --reporter expanded` | Passed, **28 tests** |
| `python -m pytest -q` from `backend` | **36 passed**, one Starlette test-client deprecation warning |
| `python -m pip check` | Passed, no broken requirements |
| `git diff --check` | Passed |
| `flutter build apk --debug --no-pub` | Attempted, blocked locally: **No Android SDK found** |
| PowerShell helper / Android Studio Run | Documented and source-reviewed; not executed on Windows here |
| Release APK | Not attempted, no private release signing configuration |

Initial checks found seven style lints and widget-test finder/scrolling mismatches; these were fixed before the passing final runs. A command accidentally run at repository root found no `test` directory; the actual successful suite ran from `mobile/`.

New tests exercise fixed HTTPS BYOK routes and headers, model catalog parsing, invalid input, UTF-8 request/output size bounds, provider failures/redirects, credential redaction, token-field adaptation, throttling, guest typing/provider navigation/save, conversation persistence with an injected test transport, keyboard layout, bilingual lesson coverage and quiz feedback/persistence. All provider transports in tests are mocked; no real paid AI call occurred. Secure-storage tests use plugin mocks. No physical-device test, live Supabase/RLS check or runner isolation audit was performed. Migration 003 has not been applied to a live project.

The previous published commit `5e2c311` **did** build a debug APK successfully in GitHub Actions: [run 37901972814](https://github.com/Piangpi1997/myanmar-ai-coding-academy/actions/runs/37901972814). That artifact predates the guest AI fixes and should not be used to verify this update. The new commit's CI outcome/artifact is reported on the PR and Actions page after push; a previous successful build is not evidence for the new source.

Current usage and limitations: [Guest BYOK update](GUEST_BYOK_UPDATE.md). Next milestone: real provider + Android secure-storage/keyboard testing, then live Supabase progress and audited sandbox execution.

## Historical foundation checks (0.2.0)

| Command | Actual result |
|---|---|
| `pip install -r requirements.txt` in isolated Python 3.12 environment | Installed successfully; exact resolved versions recorded in `backend/requirements.lock.txt` |
| `python -m pip check` | Passed: no broken requirements |
| `python -m pytest -q` from `backend/` | **36 passed**, one Starlette test-client deprecation warning |
| `python -m compileall -q backend/app` | Passed |
| `flutter pub get --offline` | Passed using official package archives with SHA256 verification; committed mobile dependency lock |
| `flutter gen-l10n` | Passed |
| `flutter analyze` | Passed: **no issues found** |
| `flutter test --reporter expanded` | Passed: **10 tests** |
| `git diff --check` | Passed |
| `flutter build apk --debug` | Attempted; failed: **No Android SDK found** |
| Release APK | Not attempted: no Android SDK or private release signing configuration |

Flutter 3.35.7 / Dart 3.9.2 were used. Commands ran with `CI=true`, `FLUTTER_SUPPRESS_ANALYTICS=true`, `TAR_OPTIONS=--no-same-owner` to avoid infrastructure probing and incompatible archive ownership in this environment. An online dependency resolution initially stalled; offline resolution subsequently succeeded. Initial analysis identified deprecated APIs/style issues; they were repaired. Initial test compilation exposed an inferred collection type issue; an explicit `Set<String>` fixed it. Initial test engine crashes were traced to a truncated SDK `flutter_tester` binary (28,573,696 bytes instead of 33,800,408). Restoring it from the official engine archive resolved the crashes; the final normal test suite passed.

## Coverage and practical limits

Backend checks cover signed JWT claims/expiry/audience/issuer/role, authorization isolation, validation/error redaction, body bounds, per-user quotas, fixed provider routing/key forwarding, upstream failures/redirects, runner resource requests, actual-result decoding and invalid runner tokens. Upstream services and PostgREST are substituted in these tests. These results do **not** verify a real provider account, real Supabase RLS, runner kernel isolation or billing.

Mobile checks cover the existing lesson catalog, Home/Learn navigation, instant language switching with preference persistence, legacy plaintext-session removal without deleting learning history, project-scoped PKCE storage, Python indentation, account-scoped BYOK storage behavior, guest/account progress separation, offline retry, delayed responses after an account switch and concurrent completion persistence. Storage tests use plugin mocks; Android keystore/device behavior still needs a physical-device test.

No Supabase credentials, provider keys, Judge0 deployment or signing keystore were supplied. Migration 002 was written but not applied to a live database. No actual user code or paid AI request was executed against a remote service. No APK was generated locally. No physical-device/manual end-to-end workflow or vulnerability/database-policy scan was completed. The CI workflow is provided to repeat analysis/tests and build a guest-mode debug APK on an Android-equipped runner; its remote outcome must be checked separately.

## Next milestone

Configure the intended Supabase project and HTTPS backend, apply migrations, audit and configure the isolated runner, then validate registration/verification/recovery, two-account progress, BYOK tutoring and real Python execution on Android. Add isolated web preview and graded beginner exercises after that integration milestone.
