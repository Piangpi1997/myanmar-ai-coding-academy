-- Preserve existing lesson IDs and progress; seed only the new beginner lessons.
-- Apply after 001 and 002 before syncing py-11 or py-12 completion.
insert into public.lessons(id,course_id,title_my,title_en,sort_order) values
('py-11','python-zero','Dictionary နှင့် Key / Value','Dictionaries',11),
('py-12','python-zero','အမှားများကို ကိုင်တွယ်ခြင်း','Error Handling',12)
on conflict(id) do nothing;
