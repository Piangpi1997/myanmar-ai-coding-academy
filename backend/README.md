# FastAPI / Supabase learning progress API

## Setup

1. Create a Supabase project and execute `database/migrations/001_learning_foundation.sql` in SQL editor.
2. Enable email authentication in Supabase Auth. Choose your email confirmation policy.
3. In `backend/`, copy `.env.example` to `.env` and insert your project URL and **publishable anon key** (never service-role key).
4. Create a Python 3.11+ environment and install dependencies.

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
pytest -q
```

On Windows activate with `.venv\\Scripts\\activate`.

Endpoints:
- `GET /health`: readiness smoke check (does not validate Supabase)
- `GET /api/v1/progress`: bearer-authenticated progress
- `PUT /api/v1/progress/{lesson_id}`: mark a valid seeded lesson complete

Authentication verifies asymmetric Supabase JWTs against the project's JWKS. Ensure your Supabase project is configured to issue RS256/ES256 tokens (legacy HS256 setups require a deliberate secure migration). The backend forwards the **user's JWT** and publishable key to Supabase REST so Row Level Security applies. No service key is used.

This is not a production deployment: configure TLS, restricted CORS/origins as needed, monitoring, request limits and migrations before release. Do not expose server development mode on public networks.
