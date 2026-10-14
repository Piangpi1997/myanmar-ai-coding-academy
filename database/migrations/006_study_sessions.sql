-- Private user-owned foreground study checkpoints. Apply after 005.
-- client_id is generated on-device and makes retries idempotent per account.
create table if not exists public.study_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  client_id uuid not null,
  started_at timestamptz not null,
  duration_seconds integer not null check (duration_seconds between 1 and 86400),
  activity text not null check (activity in ('lesson', 'coding', 'review')),
  lesson_id text check (lesson_id is null or lesson_id ~ '^[a-z0-9-]{1,64}$'),
  created_at timestamptz not null default now(),
  unique (user_id, client_id)
);

create index if not exists study_sessions_owner_time
  on public.study_sessions(user_id, started_at desc);

alter table public.study_sessions enable row level security;
revoke all on public.study_sessions from anon, authenticated;
grant select, insert, delete on public.study_sessions to authenticated;
grant all on public.study_sessions to service_role;

drop policy if exists "Study sessions: own read" on public.study_sessions;
create policy "Study sessions: own read"
  on public.study_sessions for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Study sessions: own insert" on public.study_sessions;
create policy "Study sessions: own insert"
  on public.study_sessions for insert to authenticated
  with check (user_id = (select auth.uid()));

drop policy if exists "Study sessions: own delete" on public.study_sessions;
create policy "Study sessions: own delete"
  on public.study_sessions for delete to authenticated
  using (user_id = (select auth.uid()));
