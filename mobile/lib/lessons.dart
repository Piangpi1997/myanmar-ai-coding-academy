import 'lesson_models.dart';
import 'generated/python_course.dart';
export 'lesson_models.dart' show Lesson;

const foundationLessons = <Lesson>[
  Lesson(
    id: 'py-01',
    flow: ["Source / Code", "Interpreter / လုပ်ဆောင်", "Output / ရလဒ်"],
    titleMy: 'Python ကို စတင်လေ့လာခြင်း',
    titleEn: 'Introduction to Python',
    summaryMy: 'Python ဆိုတာ ဘာလဲ၊ ဘယ်နေရာတွေမှာ သုံးလဲ။',
    bodyMy:
        'Python သည် စတင်လေ့လာသူများအတွက် ဖတ်ရှုရလွယ်ကူသော Programming Language တစ်ခုဖြစ်သည်။ Website Backend, Automation, Data Analysis နှင့် AI စသည့် လုပ်ငန်းများတွင် အသုံးပြုကြသည်။ Program ဆိုသည်မှာ ကွန်ပျူတာကို လုပ်ဆောင်စေလိုသော ညွှန်ကြားချက်များ ဖြစ်သည်။',
    code: 'print("Hello, Myanmar!")',
    challengeMy: 'ကိုယ့်နာမည်ကို print() ဖြင့် ပြသပါ။',
    answer: "print(\"My name is Mya\")\nprint(\"I want to learn Python\")",
  ),
  Lesson(
    id: 'py-02',
    flow: ["Expression / တွက်ချက်", "Binding / နာမည်ချည်", "Read / ပြန်ဖတ်"],
    titleMy: 'Variable နှင့် Data',
    titleEn: 'Variables and Data',
    summaryMy: 'တန်ဖိုးတွေကို နာမည်ပေးပြီး သိမ်းဆည်းခြင်း။',
    bodyMy:
        'Variable သည် တန်ဖိုးတစ်ခုကို နာမည်ပေး၍ သိမ်းထားရန် သုံးသည်။ = သင်္ကေတသည် ညာဘက်ရှိ တန်ဖိုးကို ဘယ်ဘက်ရှိ Variable ထဲ သတ်မှတ်ပေးသည်။ Python မှာ Variable ကို သုံးမီ အမျိုးအစား ကြိုတင်မကြေညာလည်း ရသည်။',
    code: 'name = "Su Su"\nage = 18\nprint(name)\nprint(age)',
    challengeMy: 'city ဆိုသော Variable တစ်ခု တည်ဆောက်ပြီး print() ဖြင့် ပြပါ။',
    answer:
        "city = \"Yangon\"\npopulation = 100\npopulation += 1\nprint(city)\nprint(population)",
  ),
  Lesson(
    id: 'py-03',
    flow: ["String / စာသား", "Convert / ပြောင်း", "Number / ကိန်း"],
    titleMy: 'String နှင့် Number',
    titleEn: 'Strings and Numbers',
    summaryMy: 'စာသားနှင့် ကိန်းဂဏန်းများ၏ ကွာခြားချက်။',
    bodyMy:
        'String သည် quotation mark အတွင်းရှိ စာသားဖြစ်သည်။ Integer သည် ကိန်းပြည့်၊ Float သည် ဒဿမကိန်း ဖြစ်သည်။ String နှင့် Number ကို တိုက်ရိုက်ပေါင်း၍ မရနိုင်သော အခြေအနေများရှိသဖြင့် str() သို့ int() ဖြင့် ပြောင်းသုံးရသည်။',
    code: 'name = "Mya"\nscore = 95\nprint(name + ": " + str(score))',
    challengeMy: 'price = 12.5 ကို print() ဖြင့် ပြပါ။',
    answer:
        "price = 12.5\nquantity = 2\ntotal = price * quantity\nprint(\"Total:\", total)",
  ),
  Lesson(
    id: 'py-04',
    flow: ["Input / လက်ခံ", "Convert / ပြောင်း", "Output / ပြ"],
    titleMy: 'User Input',
    titleEn: 'User Input',
    summaryMy: 'အသုံးပြုသူဆီက အချက်အလက် လက်ခံခြင်း။',
    bodyMy:
        'input() သည် အသုံးပြုသူထံမှ စာသား လက်ခံသည်။ ရလာသော တန်ဖိုးသည် String ဖြစ်သဖြင့် ကိန်းတွက်လိုလျှင် int() သို့ float() ဖြင့် ပြောင်းရသည်။',
    code: 'name = input("Your name: ")\nprint("Hello, " + name)',
    challengeMy: 'အသက်ကို input ဖြင့် လက်ခံပြီး ပြသပါ။',
    answer: "age_text = input(\"Age: \")\nage = int(age_text)\nprint(age + 1)",
  ),
  Lesson(
    id: 'py-05',
    flow: [
      "Operands / တန်ဖိုးများ",
      "Operator / လုပ်ဆောင်ချက်",
      "Result / ရလဒ်",
    ],
    titleMy: 'Operators',
    titleEn: 'Operators',
    summaryMy: 'ပေါင်း၊ နှုတ်၊ မြှောက်၊ စားနှင့် နှိုင်းယှဉ်ခြင်း။',
    bodyMy:
        '+, -, *, / သည် သင်္ချာတွက်ချက်ရန် သုံးသည်။ // သည် ကိန်းပြည့်စားရလဒ်၊ % သည် အကြွင်းကို ပြသည်။ == နှင့် != သည် တူ/မတူ နှိုင်းယှဉ်ရန် သုံးသည်။',
    code: 'a = 10\nb = 3\nprint(a + b)\nprint(a % b)',
    challengeMy: '12 ကို 5 ဖြင့်စားပြီး အကြွင်းကို ပြပါ။',
    answer: "print(12 % 5)\nn = 12\nprint(n % 2 == 0)",
  ),
  Lesson(
    id: 'py-06',
    flow: ["Condition / စစ်", "Branch / ရွေး", "Action / လုပ်"],
    titleMy: 'If / Else',
    titleEn: 'Conditions',
    summaryMy: 'အခြေအနေပေါ်မူတည်၍ ဆုံးဖြတ်ခြင်း။',
    bodyMy:
        'if သည် Condition မှန်ကန်လျှင် အောက်ပါ Code ကို လုပ်ဆောင်စေသည်။ else သည် မမှန်သည့်အခါ လုပ်ဆောင်သည်။ Python တွင် indentation (နေရာလွတ်) မှန်ကန်ဖို့ အရေးကြီးသည်။',
    code:
        'age = 20\nif age >= 18:\n    print("Adult")\nelse:\n    print("Minor")',
    challengeMy: 'score >= 50 ဖြစ်လျှင် Pass ဟု ပြပါ။',
    answer:
        "score = 60\nif score >= 80:\n    print(\"A\")\nelif score >= 50:\n    print(\"Pass\")\nelse:\n    print(\"Fail\")",
  ),
  Lesson(
    id: 'py-07',
    flow: ["Sequence / စာရင်း", "Next item / နောက်အရာ", "Body / လုပ်ဆောင်"],
    titleMy: 'For Loop',
    titleEn: 'For Loops',
    summaryMy: 'အလုပ်တစ်ခုကို ထပ်ခါတလဲလဲ လုပ်ဆောင်ခြင်း။',
    bodyMy:
        'for loop ဖြင့် အရာများကို တစ်ခုချင်း လှည့်ပတ်ကြည့်နိုင်သည်။ range(5) သည် 0 မှ 4 ထိ ထုတ်ပေးသည်။ Loop အတွင်းရှိ Code ကို indent လုပ်ရသည်။',
    code: 'for number in range(5):\n    print(number)',
    challengeMy: '1 မှ 5 ထိ ကိန်းတွေကို print လုပ်ပါ။',
    answer:
        "total = 0\nfor n in range(1, 6):\n    print(n)\n    total += n\nprint(\"Total:\", total)",
  ),
  Lesson(
    id: 'py-08',
    flow: ["Condition / စစ်", "Body / လုပ်ဆောင်", "Update / ပြောင်း"],
    titleMy: 'While Loop',
    titleEn: 'While Loops',
    summaryMy: 'Condition မှန်နေသရွေ့ ထပ်မံလုပ်ဆောင်ခြင်း။',
    bodyMy:
        'while loop သည် Condition မှန်နေသရွေ့ ဆက်လက်အလုပ်လုပ်သည်။ Condition ကို မပြောင်းမိလျှင် Infinite Loop ဖြစ်နိုင်သောကြောင့် ရပ်တန့်မည့် အခြေအနေကို စဉ်းစားပါ။',
    code: 'count = 1\nwhile count <= 3:\n    print(count)\n    count += 1',
    challengeMy: 'while loop ဖြင့် 1 မှ 5 ထိ ပြပါ။',
    answer: "n = 5\nwhile n >= 1:\n    print(n)\n    n -= 1\nprint(\"Done\")",
  ),
  Lesson(
    id: 'py-09',
    flow: ["List / စာရင်း", "Index / ရွေး", "Item / တန်ဖိုး"],
    titleMy: 'List နှင့် Collection',
    titleEn: 'Lists',
    summaryMy: 'တန်ဖိုးအများကြီးကို စုစည်းထားခြင်း။',
    bodyMy:
        'List သည် တန်ဖိုးများစွာကို အစဉ်လိုက် သိမ်းဆည်းသည်။ Index သည် 0 မှ စသည်။ append() ဖြင့် အရာအသစ်ထည့်နိုင်သည်။ for loop ဖြင့် List ထဲက တန်ဖိုးများကို ဖတ်နိုင်သည်။',
    code:
        'fruits = ["apple", "mango"]\nfruits.append("banana")\nfor fruit in fruits:\n    print(fruit)',
    challengeMy: 'အရောင် 3 ခုပါသော List တစ်ခု ဆောက်ပါ။',
    answer:
        "colors = [\"red\", \"green\", \"blue\"]\ncolors.append(\"purple\")\nprint(colors[0])\nprint(len(colors))",
  ),
  Lesson(
    id: 'py-10',
    flow: ["Arguments / ပို့", "Function / လုပ်", "Return / ပြန်"],
    titleMy: 'Function တည်ဆောက်ခြင်း',
    titleEn: 'Functions',
    summaryMy: 'ပြန်လည်အသုံးပြုနိုင်သော Code အစုများ။',
    bodyMy:
        'Function သည် လုပ်ငန်းတစ်ခုကို နာမည်ပေးထားသော Code အစုဖြစ်သည်။ def ဖြင့် သတ်မှတ်ပြီး ခေါ်သုံးနိုင်သည်။ Parameter ဖြင့် Input လက်ခံ၍ return ဖြင့် ရလဒ် ပြန်ပေးနိုင်သည်။',
    code:
        'def greet(name):\n    return "Hello, " + name\n\nprint(greet("Mya"))',
    challengeMy:
        'ကိန်းနှစ်ခု ပေါင်းပြီး return ပြန်ပေးသော add() Function ရေးပါ။',
    answer:
        "def add(a, b):\n    return a + b\n\nprint(add(2, 3))\nprint(add(0, 0))\nprint(add(-2, 2))",
  ),
  Lesson(
    id: 'py-11',
    flow: ["Key / နာမည်", "Lookup / ရှာ", "Value / တန်ဖိုး"],
    titleMy: 'Dictionary နှင့် Key / Value',
    titleEn: 'Dictionaries',
    summaryMy: 'Key ဖြင့် အချက်အလက် ရှာဖတ်၊ ပြင်ဆင်ခြင်း။',
    bodyMy:
        'Dictionary သည် unique key နှင့် value များကို စုံတွဲအဖြစ် သိမ်းသည်။ get() ဖြင့် မရှိသော key ကို default ပြန်ပေးနိုင်သည်။',
    code:
        'student = {"name": "Mya", "score": 85}\nprint(student["name"])\nprint(student.get("city", "Unknown"))',
    challengeMy: 'name၊ city ပါသော profile dictionary တည်ဆောက်ပါ။',
    answer:
        'profile = {"name": "Mya", "city": "Yangon"}\nprofile["city"] = "Mandalay"\nprint(profile.get("email", "Not provided"))',
  ),
  Lesson(
    id: 'py-12',
    flow: ["Try / လုပ်", "Exception / အမှား", "Recover / ဖြေရှင်း"],
    titleMy: 'အမှားများကို ကိုင်တွယ်ခြင်း',
    titleEn: 'Error Handling',
    summaryMy:
        'Exception ကို နားလည်၍ အသုံးပြုသူကို ရှင်းလင်းစွာ လမ်းညွှန်ခြင်း။',
    bodyMy:
        'try / except ဖြင့် မျှော်လင့်ထားသော exception ကို သတ်သတ်မှတ်မှတ် ကိုင်တွယ်နိုင်သည်။ Invalid input ကို success အဖြစ် မဖုံးကွယ်ပါနှင့်။',
    code:
        'try:\n    age = int(input("Age: "))\n    print(age + 1)\nexcept ValueError:\n    print("Please enter a valid integer.")',
    challengeMy: 'Invalid text နှင့် negative age ကို ကိုင်တွယ်ပါ။',
    answer:
        'try:\n    age = int(input("Age: "))\n    if age < 0:\n        print("Age cannot be negative.")\n    else:\n        print(age + 1)\nexcept ValueError:\n    print("Please enter a valid integer.")',
  ),
];

const pythonLessons = <Lesson>[...foundationLessons, ...extendedLessons];
