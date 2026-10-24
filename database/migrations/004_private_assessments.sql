-- Only the trusted backend may write sandbox assessment results. Learners can
-- read their own records; user-controlled public self-checks are separate.
create table if not exists public.coding_exercises (
  id text primary key,
  lesson_id text not null references public.lessons(id),
  title_my text not null,
  title_en text not null
);
create table if not exists public.code_submissions (
  id uuid primary key,
  user_id uuid not null references auth.users(id) on delete cascade,
  exercise_id text not null references public.coding_exercises(id),
  code_hash text not null check (code_hash ~ '^[a-f0-9]{64}$'),
  state text not null check (state in ('pending','complete','error')),
  passed_count integer not null default 0,
  total_count integer not null check (total_count between 1 and 3),
  feedback text not null check (feedback in ('pending','passed','wrong_answer','runtime_error','timeout','output_limit','service_unavailable')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (passed_count between 0 and total_count),
  check ((state = 'pending' and feedback = 'pending') or
    (state = 'complete' and feedback in ('passed','wrong_answer','runtime_error','timeout','output_limit')) or
    (state = 'error' and feedback in ('timeout','service_unavailable'))),
  check (feedback <> 'passed' or passed_count = total_count)
);
create index if not exists code_submissions_owner_time on public.code_submissions(user_id,created_at desc);
alter table public.coding_exercises enable row level security;
alter table public.code_submissions enable row level security;
revoke all on public.coding_exercises, public.code_submissions from anon, authenticated;
grant select on public.coding_exercises to anon, authenticated;
grant select on public.code_submissions to authenticated;
grant all on public.coding_exercises, public.code_submissions to service_role;
drop policy if exists "Exercises: public read" on public.coding_exercises;
create policy "Exercises: public read" on public.coding_exercises for select to anon, authenticated using (true);
drop policy if exists "Submissions: own read" on public.code_submissions;
create policy "Submissions: own read" on public.code_submissions for select to authenticated using (user_id = (select auth.uid()));
-- No student insert/update/delete policies. Do not expose this server-only key.
insert into public.coding_exercises(id,lesson_id,title_my,title_en) values
('sum-two','py-04','ကိန်းနှစ်ခု ပေါင်းခြင်း','Add two integers'),
('even-number','py-06','စုံကိန်းနှင့် မကိန်း','Even or odd'),
('discount-price','py-05','လျှော့ဈေး တွက်ခြင်း','Discount calculator'),
('count-vowels','py-07','Vowel အရေအတွက်','Count vowels'),
('sum-list','py-09','List ပေါင်းလဒ်','Sum a list'),
('safe-age','py-12','အသက် input စစ်ဆေးခြင်း','Validate an age')
on conflict(id) do nothing;
