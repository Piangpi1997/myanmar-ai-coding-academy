# Myanmar AI Coding Academy

Myanmar-first coding education built on the existing Flutter Android app, FastAPI backend and Supabase/PostgreSQL foundation.

## Current development milestone

The source now includes guest lessons, account-separated progress synchronization, email authentication and recovery, encrypted session storage, a Python editor with a Judge0 execution adapter, and a BYOK AI Tutor. Learners choose OpenRouter, DeepSeek, Groq or OpenAI and supply their own key through encrypted guest/account settings. Direct BYOK tutoring works without Supabase login. Keys are never embedded in the APK or stored in the backend database.

This is a tested development milestone, not the completed academy or a production release. Live Supabase/provider/runner configuration and Android device verification remain required. The ten existing IDs are preserved. There are now 36 original bilingual lessons across beginner, intermediate, advanced and professional topics, with examples, hints, solutions and local quizzes. Learn supports search, level/completion filters, concept flows and computer-only environment notices. The Android Code Lab includes encrypted HTML/CSS/JavaScript drafts and an offline restricted native WebView preview. Seven learning paths, six server-graded challenge contracts and sixteen guided project workflows are also included. The rest of the 100-lesson curriculum, reminders and admin CMS remain future work; live grading requires configured Supabase and a verified sandbox.

- [Expanded curriculum and restricted web preview](docs/COURSE_AND_WEB_LAB.md)
- [Learning paths, challenges and project workflows](docs/LEARNING_WORKSPACE.md)
- [Guest BYOK fixes and expanded beginner module](docs/GUEST_BYOK_UPDATE.md)
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
