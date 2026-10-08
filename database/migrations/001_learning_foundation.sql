-- Run in Supabase SQL editor. RLS is mandatory for authenticated data.
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  preferred_language text not null default 'my' check (preferred_language in ('my','en')),
  created_at timestamptz not null default now()
);
create table if not exists public.courses (
  id text primary key,
  title_my text not null,
  title_en text not null,
  created_at timestamptz not null default now()
);
create table if not exists public.lessons (
  id text primary key,
  course_id text not null references public.courses(id),
  title_my text not null,
  title_en text not null,
  sort_order integer not null,
  unique(course_id,sort_order)
);
create table if not exists public.lesson_progress (
  user_id uuid not null references auth.users(id) on delete cascade,
  lesson_id text not null references public.lessons(id) on delete cascade,
  completed boolean not null default false,
  updated_at timestamptz not null default now(),
  primary key(user_id,lesson_id)
);
create or replace function public.touch_lesson_progress()
returns trigger language plpgsql as $$begin new.updated_at = now(); return new; end$$;
drop trigger if exists touch_lesson_progress on public.lesson_progress;
create trigger touch_lesson_progress before update on public.lesson_progress
for each row execute function public.touch_lesson_progress();

alter table public.profiles enable row level security;
alter table public.courses enable row level security;
alter table public.lessons enable row level security;
alter table public.lesson_progress enable row level security;

create policy "Profiles: own read" on public.profiles for select to authenticated using (id = (select auth.uid()));
create policy "Profiles: own insert" on public.profiles for insert to authenticated with check (id = (select auth.uid()));
create policy "Profiles: own update" on public.profiles for update to authenticated using (id = (select auth.uid())) with check (id = (select auth.uid()));
create policy "Courses: public read" on public.courses for select to anon, authenticated using (true);
create policy "Lessons: public read" on public.lessons for select to anon, authenticated using (true);
create policy "Progress: own read" on public.lesson_progress for select to authenticated using (user_id = (select auth.uid()));
create policy "Progress: own insert" on public.lesson_progress for insert to authenticated with check (user_id = (select auth.uid()));
create policy "Progress: own update" on public.lesson_progress for update to authenticated using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

insert into public.courses(id,title_my,title_en) values ('python-zero','Python အခြေခံ','Python Zero to Hero') on conflict(id) do nothing;
insert into public.lessons(id,course_id,title_my,title_en,sort_order) values
('py-01','python-zero','Python ကို စတင်လေ့လာခြင်း','Introduction to Python',1),
('py-02','python-zero','Variable နှင့် Data','Variables and Data',2),
('py-03','python-zero','String နှင့် Number','Strings and Numbers',3),
('py-04','python-zero','User Input','User Input',4),
('py-05','python-zero','Operators','Operators',5),
('py-06','python-zero','If / Else','Conditions',6),
('py-07','python-zero','For Loop','For Loops',7),
('py-08','python-zero','While Loop','While Loops',8),
('py-09','python-zero','List နှင့် Collection','Lists',9),
('py-10','python-zero','Function တည်ဆောက်ခြင်း','Functions',10)
on conflict(id) do nothing;
