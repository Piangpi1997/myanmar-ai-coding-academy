# Academy API — BYOK milestone

Python 3.12, FastAPI, Supabase user JWTs + RLS, transient BYOK tutor and a dedicated Judge0 adapter.

```bash
cd backend
python -m venv .venv
# Windows: .venv\Scripts\activate
source .venv/bin/activate
pip install -r requirements.lock.txt
cp .env.example .env
# Set your public Supabase config in the ignored .env; never commit credentials.
pytest -q
uvicorn app.main:app --host 127.0.0.1 --port 8000 --workers 1 --no-access-log
```

Expose this service behind a trusted HTTPS reverse proxy with a 64 KiB body cap and request timeouts. The mobile app refuses HTTP backends and does not follow redirects. Bind only to loopback behind the proxy. Do not enable request-body/header capture in proxies, tracing, analytics or crash reporters. Redact `Authorization`, `X-AI-Key`, and `X-Auth-Token` everywhere. Disable proxy caching for `/api/v1/ai/*` and use `Cache-Control: no-store`.

## Supabase

Apply SQL migrations in numbered order to the intended Supabase project. Use a **publishable/anon** key, never a service-role key. Configure asymmetric ES256/RS256 Auth signing; legacy HS256 projects must migrate to an asymmetric signing key before using this backend. The JWKS client verifies signature, expiration, issuer, audience, UUID subject and authenticated role. JWT network verification is cached and runs outside the async event loop.

Progress reads explicitly filter by the verified user ID; writes derive it from the JWT. The same user's token is forwarded to PostgREST so RLS independently enforces ownership. Migration 002 creates profiles on registration and backfills existing accounts. Migration 001 is a one-time migration, not a repeatable SQL reset. No remote migrations were applied during development.

## Endpoints

- `GET /health`: liveness only; does not claim integrations are configured.
- `GET /api/v1/progress`: own completion records.
- `PUT /api/v1/progress/{lesson_id}`: idempotent completion; existing lesson IDs only.
- `POST /api/v1/ai/chat`: user JWT plus `X-AI-Key`, with provider, model, language, mode and bounded message context.
- `POST /api/v1/code/run`: user JWT, code and stdin; genuine isolated runner response.
- `GET /docs`: generated typed OpenAPI documentation.

## BYOK

The user chooses OpenRouter, DeepSeek, Groq or OpenAI, enters a compatible model ID, and supplies their own key in the Android provider settings. The key lives in encrypted, account-scoped device storage. The backend holds it transiently in request memory, forwards it only to a fixed HTTPS provider endpoint, and never writes it to the database, environment, file, chat history or response. No arbitrary base URLs or redirects are supported. The academy backend is a trusted intermediary and can see the key during forwarding; this is explained before saving. Provider charges and data-retention terms apply to the user's own provider account. Creating keys or making live paid requests is not part of setup automation.

Supported modes: ask, explain, debug, practice, review, mentor, project. Output is Markdown, defaults to Myanmar and is explicitly unexecuted. Non-streaming requests limit model output to at most 2,048 tokens (1,024 by default). Compatibility depends on the selected model accepting the Chat Completions schema; reasoning-only or Responses-only models may fail cleanly. OpenAI requests use `max_completion_tokens`; other providers use `max_tokens`. No automatic paid retries or failover to another provider.

Single-process quotas: AI 10/minute and 100/day; code 10/minute and 200/day per user. Requests count even when upstream fails. These limits are **process-local and reset on restart**. Use one worker and a shared Redis/database limiter before running multiple workers/replicas or advertising durable quotas. Input and output are bounded and upstream errors are sanitized. These are cost guardrails, not a guaranteed monetary spending cap; users should configure provider spending limits.

## Code runner

Set `JUDGE0_URL` to your dedicated, patched HTTPS Judge0 service, configure `JUDGE0_AUTH_TOKEN` if required, and verify the Python language ID (default 71). Do not enable a public/shared runner without reviewing its security. Set `JUDGE0_SANDBOX_VERIFIED=true` only after confirming ephemeral filesystem isolation, non-privileged sandbox workers, network egress disabled by service policy, controlled dependencies, patched host/container runtime and output/resource limits. The request flag alone cannot secure a misconfigured runner.

The backend cannot execute learner code itself: it submits base64 code/stdin to Judge0 and polls the returned UUID. Limits request 2 seconds CPU, 5 seconds wall time, 64 MiB memory, one process/thread, 64 KiB generated files and no network. Returned stdout, stderr and compiler output are decoded and capped at 16,000 bytes per field. A not-ready response is a real timeout, never simulated success. A timed-out request may still complete on the runner; no automatic resubmission occurs. Missing or unverified runner configuration returns 503.

## Validation limits

Automated tests use cryptographically signed test JWTs and mocked provider, database and runner responses. They verify ownership contracts, validation, quotas, key redaction, response caps and sandbox request limits. They do not prove live Supabase RLS, actual sandbox isolation, provider availability, model quality or production hosting. Complete the live integration checklist in `docs/BYOK_MILESTONE.md` before release.
