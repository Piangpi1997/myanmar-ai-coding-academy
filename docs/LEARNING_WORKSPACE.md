# Learning workspace — 0.4.0+4

This update implements the next learning vertical slice in the existing application. It does not label the entire master specification complete.

## Student workflow

Open **Learn → Learning paths / Coding challenges / Guided projects**.

- Seven selectable paths organize the shipped lessons and guides. A selected path is saved locally under the current guest/account namespace; the available lesson count reflects actual learner-marked completion. Path descriptions identify missing advanced course material.
- Six Python challenges provide bilingual statements, public input/output examples, hints, an editable syntax-colored Python editor, local saved drafts, an explicit public-example Run action, sample solutions and server submission/check-result controls.
- Sixteen project guides cover the requested beginner, intermediate and advanced projects. Each includes objectives, requirements, architecture, five distinct workflow steps, an initial snippet, tests to perform, troubleshooting and completion requirements. Checkpoints and private notes persist locally in encrypted storage. These are guides for learners to build projects, not sixteen prebuilt applications. Checkbox completion is self-reported, not a certificate or server grade.
- Account users can open **Profile → Server assessment history** to read their latest 30 server-recorded attempts. Unknown future exercise IDs fall back to their ID instead of crashing an older app.

Existing twelve lessons, public self-check quizzes, BYOK settings/history, code drafts, auth/session behavior, language and theme choices are preserved. Signing in never imports guest history. New private screens reject stale account routes and hide prior-account data on auth changes. Unreadable local records show retry and are not overwritten merely by closing a page.

## Secure assessment architecture

`Android → authenticated FastAPI → verified Judge0 → actual stdout → server comparison → protected database record`.

Every new attempt generates three conformance cases on the server. Their input/output values are not shipped in the mobile catalog or returned through the API. Expected-output comparison happens outside the learner-controlled interpreter. Source code is submitted unchanged to the existing remote sandbox adapter; FastAPI never evaluates or executes it. Merely viewing a solution never creates a grade.

Requests require a verified user JWT. Code and IDs have bounded typed inputs; the authenticated subject supplies ownership. The database stores a SHA256 source digest and outcome metadata, not raw code, stdin or runner output. Learners may select their own records but cannot insert, update or delete grades. Server queries explicitly filter authenticated ownership even though the privileged storage credential bypasses RLS.

Each attempt receives a client UUID receipt persisted before submission. Reconnecting with the same receipt/code returns its existing record without executing again. Changing code under an existing receipt is rejected. An interrupted server can leave a pending record; the UI preserves the receipt and offers a read-only result check. Starting another attempt requires an explicit choice. There is no automatic execution retry and no paid-call simulation.

Limits: three new grading attempts/minute and 50/day per user; each sandbox case also consumes the existing execution quota (10/minute, 200/day). Assessment requests/reads have separate limits. All quotas remain process-local: use one backend worker until a shared durable limiter is implemented. Grading has a 28-second execution deadline, with existing per-case resource/output bounds. Internal runner faults are service errors, not passing grades or student syntax errors. Timeouts may leave a runner job completing later.

Three cases provide bounded practice feedback, not proof of complete correctness or mastery. Sample solutions remain public instructional material. No certificate is issued.

## Deployment

1. Apply migrations **001 → 002 → 003 → 004** to the intended Supabase project. Migration 004 adds public exercise IDs and private `code_submissions`, revokes student writes, enables RLS and grants the trusted server role write access. Existing lesson IDs/progress are retained. No live migration was applied here.
2. Set backend `SUPABASE_URL`, public `SUPABASE_ANON_KEY`, JWT audience and **`SUPABASE_SECRET_KEY`**. The new secret is backend-only; an `sb_secret_` key or legacy service-role JWT is supported. Never put it in mobile source, Dart defines, GitHub plaintext or a student prompt. Existing tutoring/progress/run endpoints do not require this new setting; graded submissions fail closed if it is absent.
3. Configure and independently audit the dedicated Judge0 deployment as documented in `backend/README.md`. Enable `JUDGE0_SANDBOX_VERIFIED` only after real isolation checks.
4. Build/run Android with the existing public Supabase/backend Dart defines. A default CI APK supports guest reading, quizzes, pathways, local project progress, saved code and direct BYOK. Real Python execution/grading requires the configured authenticated services.
5. Verify with two real accounts that direct PostgREST reads return only owned submissions and that client-role POST/PATCH/DELETE fail. Then test actual code, wrong output, runtime errors, time/output bounds, reconnect/idempotency, account switching and receipts on Android.

## Endpoints

| Method | Route | Access / result |
|---|---|---|
| GET | `/api/v1/learning/catalog` | Public typed bilingual catalog; no grading oracles |
| POST | `/api/v1/practice/{exercise_id}/submit` | Authenticated `{submission_id, code}`; persisted aggregate grade |
| GET | `/api/v1/practice/attempts/{submission_id}` | Own existing receipt only |
| GET | `/api/v1/practice/attempts` | Latest 30 owned records |

The canonical public source is `content/learning_catalog.json`. Run `python scripts/sync-learning-catalog.py` after editing it; `--check` verifies both runtime copies. CI rejects drift. Private grading generation stays in `backend/app/assessments.py` and is never copied into this catalog. Content changes require repository review until an admin CMS exists.

## References and limitations

Instruction and examples are authored for this app; project guides link to official Python, Flutter, FastAPI and Supabase documentation. Implementation references: [Judge0 API](https://ce.judge0.com/), [Supabase RLS](https://supabase.com/docs/guides/database/postgres/row-level-security), [server API keys](https://supabase.com/docs/guides/getting-started/api-keys).

No live Supabase secret, deployment, real runner or physical-device environment was supplied. Tests substitute API/database/runner transports; the additional solution checks execute only trusted authored catalog examples in child test processes with no inherited secrets. They are not live sandbox certification. Local project notes/checkpoints do not sync to cloud. The full 100-lesson curriculum, isolated web preview, reminders, achievements/certificates, admin CMS and production signing remain pending.

Next milestone in the requested priority order: expand the original Python curriculum through intermediate modules with substantial bilingual explanations and assessments. The live Supabase/runner/device integration remains a separate release gate and needs the intended deployment configuration.
