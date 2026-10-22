# Study and reminder repair — 0.6.1+7

The 0.6.0 branch head `3d35751` failed Flutter analysis with 37 diagnostics. The study-model rewrite removed the types and methods still used by the timer screen, reminder screen, Android method channel and cloud service. That workflow never reached tests or APK compilation.

This patch reconnects the existing screens to the original `StudySession`, `StudyTracker`, `StudyStore`, `ReminderPreferencesStore` and `ReminderPlatform` contracts. Existing `study.v1.<owner>` and `reminder.v1.<owner>` data and the backend/native snake-case payloads keep their original formats. No database migration is needed for this repair. The unconnected checkpoint/in-memory-storage replacement is removed.

Reminder weekday edits now deduplicate and sort a fresh list, leaving the input unchanged and exposing an immutable result. The timer records explicit foreground intervals and pauses on app lifecycle changes. A cloud synchronization now re-reads device history before merging, preserving checkpoints added while an upload was pending. New checkpoints stay pending until a later sync uploads them.

Regression coverage includes the actual timer and reminder widgets, native schedule/permission payloads, persistence and restoration, account separation, unreadable-history preservation and the in-flight-sync scenario. The existing backend API, lessons, BYOK providers and keys are not changed by this repair.

Local checks on 2026-10-23: backend **133 tests passed** with one existing Starlette/httpx deprecation warning; dependency consistency and both catalog generation checks passed. Flutter/Android tools are not installed in this editing environment. Flutter analysis, tests, Chromium preview checks and APK compilation are verified by the [validation workflow](https://github.com/Piangpi1997/myanmar-ai-coding-academy/actions/workflows/validate.yml) for the patch commit; consult that run's actual result and matching artifact.

Physical-device notifications and live provider/Supabase/runner integrations still need their configured environments. This is a debug development update with 40 lessons; the 100-lesson curriculum and administrator CMS remain unfinished.
