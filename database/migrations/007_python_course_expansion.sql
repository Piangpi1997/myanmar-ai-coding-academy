-- Additive Python course expansion; apply after 006. Preserve IDs and progress.
insert into public.lessons(id,course_id,title_my,title_en,sort_order) values
('py-37','python-zero','Big-O ဖြင့် အလုပ်ပမာဏ ခန့်မှန်းခြင်း','Big-O and measuring work',37),
('py-38','python-zero','sorted၊ key နှင့် stable sort','Sorting with keys and stability',38),
('py-39','python-zero','Recursion နှင့် ရပ်တန့်မည့် base case','Recursion and base cases',39),
('py-40','python-zero','heapq ဖြင့် အကြီးဆုံး k ခုရွေးခြင်း','Selecting top-k items with heapq',40)
on conflict(id) do nothing;
