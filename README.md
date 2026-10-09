# Myanmar AI Coding Academy

Myanmar-first coding education built on the existing Flutter Android app, FastAPI backend and Supabase/PostgreSQL foundation.

## Current development milestone

The source now includes guest lessons, account-separated progress synchronization, email authentication and recovery, encrypted session storage, a Python editor with a Judge0 execution adapter, and a BYOK AI Tutor. Learners choose OpenRouter, DeepSeek, Groq or OpenAI and supply their own key through account-scoped settings. Keys are never embedded in the APK or stored in the backend database.

This is a tested development milestone, not the completed academy or a production release. Live Supabase/provider/runner configuration and Android device verification remain required. The ten existing short lessons are preserved; the 100-lesson curriculum, web preview, grading, reminders and admin CMS are future work.

- [Implemented scope and limitations](docs/BYOK_MILESTONE.md)
- [Tests actually executed and APK status](docs/VALIDATION_REPORT.md)
- [Android setup and signing](mobile/README.md)
- [Backend configuration and security](backend/README.md)
- [Development roadmap](docs/DEVELOPMENT_ROADMAP.md)

## Original specification

The existing prompt package remains the long-term specification:

- [Master prompt](prompts/FINAL_MASTER_PROMPT.md)
- [Plain-text prompt](prompts/FINAL_MASTER_PROMPT.txt)
- [Package instructions](prompts/README.txt)
- [Original ZIP](Myanmar_AI_Coding_Academy_Final_Prompt.zip)
