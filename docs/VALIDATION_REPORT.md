# BYOK foundation validation — 2026-10-09

Base commit: `3b31c82a3c35dc10fb15109c2b119c2efa6d7767`.
Branch: `development/byok-foundation`. This report describes local checks, not production certification.

## Executed checks

| Command | Actual result |
|---|---|
| `pip install -r requirements.txt` in isolated Python 3.12 environment | Installed successfully; exact resolved versions recorded in `backend/requirements.lock.txt` |
| `python -m pip check` | Passed: no broken requirements |
| `python -m pytest -q` from `backend/` | **36 passed**, one Starlette test-client deprecation warning |
| `python -m compileall -q backend/app` | Passed |
| `flutter pub get --offline` | Passed using official package archives with SHA256 verification; committed mobile dependency lock |
| `flutter gen-l10n` | Passed |
| `flutter analyze` | Passed: **no issues found** |
| `flutter test --reporter expanded` | Passed: **8 tests** |
| `git diff --check` | Passed |
| `flutter build apk --debug` | Attempted; failed: **No Android SDK found** |
| Release APK | Not attempted: no Android SDK or private release signing configuration |

Flutter 3.35.7 / Dart 3.9.2 were used. Commands ran with `CI=true`, `FLUTTER_SUPPRESS_ANALYTICS=true`, `TAR_OPTIONS=--no-same-owner` to avoid infrastructure probing and incompatible archive ownership in this environment. An online dependency resolution initially stalled; offline resolution subsequently succeeded. Initial analysis identified deprecated APIs/style issues; they were repaired. Initial test compilation exposed an inferred collection type issue; an explicit `Set<String>` fixed it. Initial test engine crashes were traced to a truncated SDK `flutter_tester` binary (28,573,696 bytes instead of 33,800,408). Restoring it from the official engine archive resolved the crashes; the final normal test suite passed.

## Coverage and practical limits

Backend checks cover signed JWT claims/expiry/audience/issuer/role, authorization isolation, validation/error redaction, body bounds, per-user quotas, fixed provider routing/key forwarding, upstream failures/redirects, runner resource requests, actual-result decoding and invalid runner tokens. Upstream services and PostgREST are substituted in these tests. These results do **not** verify a real provider account, real Supabase RLS, runner kernel isolation or billing.

Mobile checks cover the existing lesson catalog, Home/Learn navigation, instant language switching with preference persistence, Python indentation, account-scoped BYOK storage behavior, guest/account progress separation, offline retry, delayed responses after an account switch and concurrent completion persistence. Storage tests use plugin mocks; Android keystore/device behavior still needs a physical-device test.

No Supabase credentials, provider keys, Judge0 deployment or signing keystore were supplied. Migration 002 was written but not applied to a live database. No actual user code or paid AI request was executed against a remote service. No APK was generated locally. No physical-device/manual end-to-end workflow or vulnerability/database-policy scan was completed. The CI workflow is provided to repeat analysis/tests and build a guest-mode debug APK on an Android-equipped runner; its remote outcome must be checked separately.

## Next milestone

Configure the intended Supabase project and HTTPS backend, apply migrations, audit and configure the isolated runner, then validate registration/verification/recovery, two-account progress, BYOK tutoring and real Python execution on Android. Add isolated web preview and graded beginner exercises after that integration milestone.
