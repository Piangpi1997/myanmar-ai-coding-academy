class Lesson {
  const Lesson({
    required this.id,
    required this.titleMy,
    required this.titleEn,
    required this.summaryMy,
    required this.bodyMy,
    required this.code,
    required this.challengeMy,
    required this.answer,
  });

  final String id;
  final String titleMy;
  final String titleEn;
  final String summaryMy;
  final String bodyMy;
  final String code;
  final String challengeMy;
  final String answer;
}

const pythonLessons = <Lesson>[
  Lesson(
    id: 'py-01',
    titleMy: 'Python ကို စတင်လေ့လာခြင်း',
    titleEn: 'Introduction to Python',
    summaryMy: 'Python ဆိုတာ ဘာလဲ၊ ဘယ်နေရာတွေမှာ သုံးလဲ။',
    bodyMy:
        'Python သည် စတင်လေ့လာသူများအတွက် ဖတ်ရှုရလွယ်ကူသော Programming Language တစ်ခုဖြစ်သည်။ Website Backend, Automation, Data Analysis နှင့် AI စသည့် လုပ်ငန်းများတွင် အသုံးပြုကြသည်။ Program ဆိုသည်မှာ ကွန်ပျူတာကို လုပ်ဆောင်စေလိုသော ညွှန်ကြားချက်များ ဖြစ်သည်။',
    code: 'print("Hello, Myanmar!")',
    challengeMy: 'ကိုယ့်နာမည်ကို print() ဖြင့် ပြသပါ။',
    answer: 'print("My name is Aung")',
  ),
  Lesson(
    id: 'py-02',
    titleMy: 'Variable နှင့် Data',
    titleEn: 'Variables and Data',
    summaryMy: 'တန်ဖိုးတွေကို နာမည်ပေးပြီး သိမ်းဆည်းခြင်း။',
    bodyMy:
        'Variable သည် တန်ဖိုးတစ်ခုကို နာမည်ပေး၍ သိမ်းထားရန် သုံးသည်။ = သင်္ကေတသည် ညာဘက်ရှိ တန်ဖိုးကို ဘယ်ဘက်ရှိ Variable ထဲ သတ်မှတ်ပေးသည်။ Python မှာ Variable ကို သုံးမီ အမျိုးအစား ကြိုတင်မကြေညာလည်း ရသည်။',
    code: 'name = "Su Su"\nage = 18\nprint(name)\nprint(age)',
    challengeMy: 'city ဆိုသော Variable တစ်ခု တည်ဆောက်ပြီး print() ဖြင့် ပြပါ။',
    answer: 'city = "Yangon"\nprint(city)',
  ),
  Lesson(
    id: 'py-03',
    titleMy: 'String နှင့် Number',
    titleEn: 'Strings and Numbers',
    summaryMy: 'စာသားနှင့် ကိန်းဂဏန်းများ၏ ကွာခြားချက်။',
    bodyMy:
        'String သည် quotation mark အတွင်းရှိ စာသားဖြစ်သည်။ Integer သည် ကိန်းပြည့်၊ Float သည် ဒဿမကိန်း ဖြစ်သည်။ String နှင့် Number ကို တိုက်ရိုက်ပေါင်း၍ မရနိုင်သော အခြေအနေများရှိသဖြင့် str() သို့ int() ဖြင့် ပြောင်းသုံးရသည်။',
    code: 'name = "Mya"\nscore = 95\nprint(name + ": " + str(score))',
    challengeMy: 'price = 12.5 ကို print() ဖြင့် ပြပါ။',
    answer: 'price = 12.5\nprint(price)',
  ),
  Lesson(
    id: 'py-04',
    titleMy: 'User Input',
    titleEn: 'User Input',
    summaryMy: 'အသုံးပြုသူဆီက အချက်အလက် လက်ခံခြင်း။',
    bodyMy:
        'input() သည် အသုံးပြုသူထံမှ စာသား လက်ခံသည်။ ရလာသော တန်ဖိုးသည် String ဖြစ်သဖြင့် ကိန်းတွက်လိုလျှင် int() သို့ float() ဖြင့် ပြောင်းရသည်။',
    code: 'name = input("Your name: ")\nprint("Hello, " + name)',
    challengeMy: 'အသက်ကို input ဖြင့် လက်ခံပြီး ပြသပါ။',
    answer: 'age = input("Age: ")\nprint(age)',
  ),
  Lesson(
    id: 'py-05',
    titleMy: 'Operators',
    titleEn: 'Operators',
    summaryMy: 'ပေါင်း၊ နှုတ်၊ မြှောက်၊ စားနှင့် နှိုင်းယှဉ်ခြင်း။',
    bodyMy:
        '+, -, *, / သည် သင်္ချာတွက်ချက်ရန် သုံးသည်။ // သည် ကိန်းပြည့်စားရလဒ်၊ % သည် အကြွင်းကို ပြသည်။ == နှင့် != သည် တူ/မတူ နှိုင်းယှဉ်ရန် သုံးသည်။',
    code: 'a = 10\nb = 3\nprint(a + b)\nprint(a % b)',
    challengeMy: '12 ကို 5 ဖြင့်စားပြီး အကြွင်းကို ပြပါ။',
    answer: 'print(12 % 5)',
  ),
  Lesson(
    id: 'py-06',
    titleMy: 'If / Else',
    titleEn: 'Conditions',
    summaryMy: 'အခြေအနေပေါ်မူတည်၍ ဆုံးဖြတ်ခြင်း။',
    bodyMy:
        'if သည် Condition မှန်ကန်လျှင် အောက်ပါ Code ကို လုပ်ဆောင်စေသည်။ else သည် မမှန်သည့်အခါ လုပ်ဆောင်သည်။ Python တွင် indentation (နေရာလွတ်) မှန်ကန်ဖို့ အရေးကြီးသည်။',
    code:
        'age = 20\nif age >= 18:\n    print("Adult")\nelse:\n    print("Minor")',
    challengeMy: 'score >= 50 ဖြစ်လျှင် Pass ဟု ပြပါ။',
    answer: 'score = 60\nif score >= 50:\n    print("Pass")',
  ),
  Lesson(
    id: 'py-07',
    titleMy: 'For Loop',
    titleEn: 'For Loops',
    summaryMy: 'အလုပ်တစ်ခုကို ထပ်ခါတလဲလဲ လုပ်ဆောင်ခြင်း။',
    bodyMy:
        'for loop ဖြင့် အရာများကို တစ်ခုချင်း လှည့်ပတ်ကြည့်နိုင်သည်။ range(5) သည် 0 မှ 4 ထိ ထုတ်ပေးသည်။ Loop အတွင်းရှိ Code ကို indent လုပ်ရသည်။',
    code: 'for number in range(5):\n    print(number)',
    challengeMy: '1 မှ 5 ထိ ကိန်းတွေကို print လုပ်ပါ။',
    answer: 'for n in range(1, 6):\n    print(n)',
  ),
  Lesson(
    id: 'py-08',
    titleMy: 'While Loop',
    titleEn: 'While Loops',
    summaryMy: 'Condition မှန်နေသရွေ့ ထပ်မံလုပ်ဆောင်ခြင်း။',
    bodyMy:
        'while loop သည် Condition မှန်နေသရွေ့ ဆက်လက်အလုပ်လုပ်သည်။ Condition ကို မပြောင်းမိလျှင် Infinite Loop ဖြစ်နိုင်သောကြောင့် ရပ်တန့်မည့် အခြေအနေကို စဉ်းစားပါ။',
    code: 'count = 1\nwhile count <= 3:\n    print(count)\n    count += 1',
    challengeMy: 'while loop ဖြင့် 1 မှ 5 ထိ ပြပါ။',
    answer: 'n = 1\nwhile n <= 5:\n    print(n)\n    n += 1',
  ),
  Lesson(
    id: 'py-09',
    titleMy: 'List နှင့် Collection',
    titleEn: 'Lists',
    summaryMy: 'တန်ဖိုးအများကြီးကို စုစည်းထားခြင်း။',
    bodyMy:
        'List သည် တန်ဖိုးများစွာကို အစဉ်လိုက် သိမ်းဆည်းသည်။ Index သည် 0 မှ စသည်။ append() ဖြင့် အရာအသစ်ထည့်နိုင်သည်။ for loop ဖြင့် List ထဲက တန်ဖိုးများကို ဖတ်နိုင်သည်။',
    code:
        'fruits = ["apple", "mango"]\nfruits.append("banana")\nfor fruit in fruits:\n    print(fruit)',
    challengeMy: 'အရောင် 3 ခုပါသော List တစ်ခု ဆောက်ပါ။',
    answer: 'colors = ["red", "green", "blue"]\nprint(colors)',
  ),
  Lesson(
    id: 'py-10',
    titleMy: 'Function တည်ဆောက်ခြင်း',
    titleEn: 'Functions',
    summaryMy: 'ပြန်လည်အသုံးပြုနိုင်သော Code အစုများ။',
    bodyMy:
        'Function သည် လုပ်ငန်းတစ်ခုကို နာမည်ပေးထားသော Code အစုဖြစ်သည်။ def ဖြင့် သတ်မှတ်ပြီး ခေါ်သုံးနိုင်သည်။ Parameter ဖြင့် Input လက်ခံ၍ return ဖြင့် ရလဒ် ပြန်ပေးနိုင်သည်။',
    code:
        'def greet(name):\n    return "Hello, " + name\n\nprint(greet("Mya"))',
    challengeMy:
        'ကိန်းနှစ်ခု ပေါင်းပြီး return ပြန်ပေးသော add() Function ရေးပါ။',
    answer: 'def add(a, b):\n    return a + b\n\nprint(add(2, 3))',
  ),
];
