-- Apply after 001. No BYOK keys or chat transcripts are stored in this database.
begin;
create or replace function public.create_academy_profile()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles(id, display_name, preferred_language)
  values (new.id, left(coalesce(new.raw_user_meta_data->>'display_name', ''), 100), 'my')
  on conflict(id) do nothing;
  return new;
end;
$$;
revoke all on function public.create_academy_profile() from public, anon, authenticated;
drop trigger if exists create_academy_profile on auth.users;
create trigger create_academy_profile after insert on auth.users
for each row execute function public.create_academy_profile();
insert into public.profiles(id) select id from auth.users on conflict(id) do nothing;

-- Explicit grants; RLS remains the row-level authority in 001.
grant select on public.courses, public.lessons to anon, authenticated;
grant select, insert, update on public.profiles, public.lesson_progress to authenticated;
revoke all on public.profiles, public.lesson_progress from anon;
revoke insert, update, delete on public.courses, public.lessons from anon, authenticated;
commit;
