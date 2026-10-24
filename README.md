# Myanmar AI Coding Academy

Myanmar-first coding education built on the existing Flutter Android app, FastAPI backend and Supabase/PostgreSQL foundation.

## Current development milestone

The source now includes guest lessons, account-separated progress synchronization, email authentication and recovery, encrypted session storage, a Python editor with a Judge0 execution adapter, and a BYOK AI Tutor. Learners choose OpenRouter, DeepSeek, Groq or OpenAI and supply their own key through encrypted guest/account settings. Direct BYOK tutoring works without Supabase login. Keys are never embedded in the APK or stored in the backend database.

Version 0.7.0 includes **120 original Myanmar/English lessons**: 40 Python, 20 Programming, 20 Web, 20 Linux/Kali and 20 Ethical Security. It adds subject browsing, a quieter mobile UI, Q&A tests with previews/results, and clipboard/lesson import plus full-screen HTML viewing. Existing lesson IDs, account-separated progress and encrypted drafts remain in place. Kali exercises run in owned computer/VM labs; the app does not embed a Kali runtime. This is a development milestone; live services, release signing, administrator CMS and physical-device checks remain separate work.

- [120-lesson curriculum and workspace update](docs/ACADEMY_120.md)

- [Expanded curriculum and restricted web preview](docs/COURSE_AND_WEB_LAB.md)
- [Learning paths, challenges and project workflows](docs/LEARNING_WORKSPACE.md)
- [Guest BYOK fixes and expanded beginner module](docs/GUEST_BYOK_UPDATE.md)
- [Implemented scope and limitations](docs/BYOK_MILESTONE.md)
- [Tests actually executed and APK status](docs/VALIDATION_REPORT.md)
- [Study/reminder compatibility repair (0.6.1)](docs/STUDY_REPAIR.md)
- [Android setup and signing](mobile/README.md)
- [Backend configuration and security](backend/README.md)
- [Development roadmap](docs/DEVELOPMENT_ROADMAP.md)

## Original specification

The existing prompt package remains the long-term specification:

- [Master prompt](prompts/FINAL_MASTER_PROMPT.md)
- [Plain-text prompt](prompts/FINAL_MASTER_PROMPT.txt)
- [Package instructions](prompts/README.txt)
- [Original ZIP](Myanmar_AI_Coding_Academy_Final_Prompt.zip)
