// Original bilingual beginner guides. References explain concepts; text is authored for this app.
class LessonGuide {
  const LessonGuide({
    required this.my,
    required this.en,
    required this.myOptions,
    required this.enOptions,
    required this.correct,
    required this.reference,
  });
  final Map<String, String> my, en;
  final List<String> myOptions, enOptions;
  final int correct;
  final String reference;
  Map<String, String> text(bool english) => english ? en : my;
  List<String> options(bool english) => english ? enOptions : myOptions;
}

const lessonGuides = <String, LessonGuide>{
  "py-01": LessonGuide(
    my: {
      "objectives":
          "Program၊ source code၊ output တို့ကို ခွဲခြားနိုင်ရန်။ print() ဖြင့် ပထမဆုံး program ရေးနိုင်ရန်။",
      "body":
          "သင့်မိတ်ဆွေကို လက်ဖက်ရည်ဖျော်ရန် အဆင့်လိုက် ပြောသကဲ့သို့ program ကလည်း စက်ကို ညွှန်ကြားချက်ပေးသည်။ Python interpreter က source code ကို ဖတ်၍ လုပ်ဆောင်သည်။ ရေးထားသော code သည် output မဟုတ်သေးပါ။ Run လုပ်ပြီးမှ ရလဒ်ကို သိရသည်။\n\nComputer တွင် လေ့လာမည်ဆိုလျှင် python.org မှ Python 3 ကို တင်ပြီး terminal တွင် python --version ဖြင့် စစ်ပါ။ Windows တွင် py --version ကိုလည်း သုံးနိုင်သည်။ hello.py ဖိုင်ထဲသို့ နမူနာရေးပြီး py hello.py ဖြင့် run ပါ။ ယခု mobile app တွင် နမူနာကို Code Lab သို့ ပို့၍ ဖတ်ရှု၊ ပြင်ဆင်၊ သိမ်းနိုင်သည်။ Python Run အတွက် administrator ချိတ်ဆက်ထားသော sandbox backend နှင့် account လိုသည်။\n\nprint() သည် parentheses အတွင်းက တန်ဖိုးကို output ဆီ ပို့သည်။ စာသားကို quotes နှစ်ဖက်ညီအောင် ပိတ်ရသည်။ Myanmar Unicode စာသားကိုလည်း quotes အတွင်းရေးနိုင်သည်။ print တစ်ခါတိုင်း ပုံမှန်အားဖြင့် စာကြောင်းအသစ်တစ်ခု စသည်။ ဤနမူနာမှ မျှော်မှန်းရလဒ်မှာ Hello, Myanmar! ဖြစ်သည်။ မျှော်မှန်းချက်ကို အမှန်တကယ် execution နှင့် မရောပါနှင့်။",
      "lines":
          "၁။ print သည် output ထုတ်သော built-in function ဖြစ်သည်။\n၂။ \"Hello, Myanmar!\" သည် စာသားတန်ဖိုး ဖြစ်သည်။\n၃။ parentheses များက function ကို ခေါ်ပြီး argument ကို ပို့သည်။",
      "mistake":
          "Print ဟု capital P ရေးလျှင် print နှင့် မတူပါ။ quote သို့မဟုတ် closing parenthesis ပျောက်လျှင် syntax error ဖြစ်နိုင်သည်။",
      "hint": "နမူနာထဲက quotes အတွင်းစာသားကိုသာ ကိုယ့်နာမည်ဖြင့် အစားထိုးပါ။",
      "challenge":
          "ကိုယ့်နာမည်နှင့် လေ့လာချင်သော skill ကို print နှစ်ကြောင်းဖြင့် ပြပါ။",
      "question": "print(\"Mya\") တွင် စာသား argument သည် ဘယ်ဟာလဲ။",
      "explanation":
          "\"Mya\" သည် function ထံပို့သော string argument ဖြစ်သည်။ print က function နာမည် ဖြစ်သည်။",
    },
    en: {
      "objectives":
          "Distinguish source code from output; write and run a first print statement.",
      "body":
          "A program is an ordered set of instructions, like a recipe with precise steps. The Python interpreter reads source code and performs those instructions. Code written in an editor is not an executed result.\n\nOn a computer, install Python 3 from python.org and check python --version, or py --version on Windows. Save the example in hello.py and run py hello.py. In this Android app, send an example to Code Lab to edit and save it. Running Python requires an account and a configured, isolated backend sandbox. Reading lessons does not.\n\nThe built-in print function sends its argument to standard output. Quotes mark text; they are not part of the displayed value. Opening and closing quotes must match. Unicode text, including Myanmar, can appear inside a string. Each print call normally ends with a newline. The expected output of this example is Hello, Myanmar!, but this explanation does not claim an execution occurred.",
      "lines":
          "1. print names the built-in output function.\n2. \"Hello, Myanmar!\" is the string argument.\n3. Parentheses call the function with that argument.",
      "mistake":
          "Python is case sensitive: Print and print are different names. Missing a quote or closing parenthesis can cause a SyntaxError.",
      "hint":
          "Replace the text inside the quotes while keeping print and the parentheses.",
      "challenge":
          "Print your name and a skill you want to learn on two separate lines.",
      "question": "Which part of print(\"Mya\") is the string argument?",
      "explanation":
          "\"Mya\" is the string argument passed to the function. print is the function name.",
    },
    myOptions: ["print", "\"Mya\"", "()"],
    enOptions: ["print", "\"Mya\"", "()"],
    correct: 1,
    reference: "https://docs.python.org/3/tutorial/introduction.html",
  ),
  "py-02": LessonGuide(
    my: {
      "objectives":
          "နာမည်နှင့် တန်ဖိုးကို ချိတ်ဆက်နိုင်ရန်။ assignment နှင့် comparison ကွာခြားချက် သိရန်။",
      "body":
          "Variable ကို တန်ဖိုးတစ်ခု၏ အမည်ကတ်အဖြစ် စဉ်းစားပါ။ name = \"Su Su\" ဆိုလျှင် name အမည်သည် string တန်ဖိုးကို ရည်ညွှန်းသည်။ Python က ညာဘက် expression ကို အရင်တွက်ပြီး ဘယ်ဘက်နာမည်နှင့် ချိတ်ဆက်ပေးသည်။ ထို့ကြောင့် age = age + 1 ဆိုသည်မှာ အသက်ဟောင်းကို ဖတ်၊ ၁ ပေါင်း၊ တန်ဖိုးအသစ် ပြန်သတ်မှတ်ခြင်း ဖြစ်သည်။\n\nတူညီသောနာမည်ကို နောက်တစ်ကြိမ် assign လုပ်နိုင်သည်။ age = 18 ပြီး age = 19 ဟု ရေးလျှင် နောက်ပိုင်း print(age) က 19 ကို ပြမည်။ Quotes အတွင်းရှိ \"age\" က variable မဟုတ်ဘဲ စာသားဖြစ်သည်။ သုံးမီ assign မလုပ်ထားသောနာမည်ကို ဖတ်လျှင် NameError ရနိုင်သည်။\n\nနာမည်တွင် letter သို့ underscore ဖြင့် စပြီး number နောက်မှ ထည့်နိုင်သည်။ full_name ကဲ့သို့ ရှင်းလင်းသောနာမည် သုံးပါ။ Space၊ hyphen၊ Python keyword ကို မသုံးပါနှင့်။ = သည် assign လုပ်ခြင်းဖြစ်ပြီး == သည် နှိုင်းယှဉ်ခြင်း ဖြစ်သည်။ တန်ဖိုးနှစ်ခု တူသည်ဟု = ဖြင့် စစ်၍ မရပါ။",
      "lines":
          "၁။ name ကို \"Su Su\" နှင့် ချိတ်သည်။\n၂။ age ကို integer 18 နှင့် ချိတ်သည်။\n၃။ print(name) က name ၏ တန်ဖိုးကို ဖတ်၍ ပြသည်။\n၄။ print(age) က age ၏ တန်ဖိုးကို ပြသည်။",
      "mistake":
          "print(city) မလုပ်မီ city ကို သတ်မှတ်ပါ။ name နှင့် Name သည် မတူသောနာမည်များ ဖြစ်သည်။",
      "hint":
          "city = \"Yangon\" ကို ရေးပြီး နောက်စာကြောင်းတွင် print(city) ရေးပါ။",
      "challenge":
          "city နှင့် population variable နှစ်ခု တည်ဆောက်ပါ။ population ကို ၁ တိုးပြီး နှစ်ခုလုံး ပြပါ။",
      "question": "x = 2 ပြီး x = x + 3 လုပ်လျှင် x သည် ဘယ်လောက်လဲ။",
      "explanation":
          "ညာဘက်ရှိ x အဟောင်း 2 နှင့် 3 ပေါင်းပြီး ရလဒ် 5 ကို x ထဲ ပြန်သတ်မှတ်သည်။",
    },
    en: {
      "objectives":
          "Bind names to values; distinguish assignment from comparison.",
      "body":
          "Think of a variable as a label referring to a value. Assignment evaluates the expression on the right and binds the name on the left. Thus age = age + 1 reads the old age, adds one, then assigns the new result.\n\nYou can reassign a name. After age = 18 and age = 19, a later print(age) reads 19. In contrast, print(\"age\") displays the literal word age. Reading a name before assigning it can raise NameError.\n\nUse meaningful names such as full_name. A name can start with a letter or underscore and contain digits later. Spaces and hyphens are unsuitable, and reserved keywords cannot be variable names. The equals sign assigns a value; two equals signs compare values. Python permits names to refer to values of different types over time, but surprising type changes make programs harder to understand.",
      "lines":
          "1. Bind name to the string \"Su Su\".\n2. Bind age to the integer 18.\n3. Read and print the value of name.\n4. Read and print the value of age.",
      "mistake":
          "Assign city before reading it. name and Name are different identifiers.",
      "hint":
          "Assign a quoted city name, then print the variable without quotes.",
      "challenge":
          "Create city and population variables, increase population by one, and print both.",
      "question": "After x = 2 and x = x + 3, what value does x refer to?",
      "explanation":
          "The right side reads the old value 2, adds 3, then binds x to 5.",
    },
    myOptions: ["2", "3", "5"],
    enOptions: ["2", "3", "5"],
    correct: 2,
    reference: "https://docs.python.org/3/tutorial/introduction.html#numbers",
  ),
  "py-03": LessonGuide(
    my: {
      "objectives":
          "str၊ int၊ float ကို ခွဲခြားပြီး type conversion လုပ်နိုင်ရန်။",
      "body":
          "\"95\" သည် စာသားဖြစ်ပြီး 95 သည် integer ဖြစ်သည်။ 12.5 သည် float ဖြစ်သည်။ တူညီသလို မြင်ရသော်လည်း လုပ်ဆောင်ပုံ မတူပါ။ \"2\" + \"3\" က \"23\" ဟူသော စာသားဆက်ခြင်း ဖြစ်ပြီး 2 + 3 က 5 ဖြစ်သည်။ type(value) ဖြင့် အမျိုးအစား စစ်နိုင်သည်။\n\nString ထဲတွင် လိုင်းအသစ်ကို \\n၊ quote ကို backslash ဖြင့် escape လုပ်နိုင်သည်။ Number ကို string နှင့် တိုက်ရိုက် + လုပ်မည့်အစား str(number) ဖြင့် ပြောင်းပါ။ ပိုဖတ်လွယ်သော နည်းမှာ print(name, score) သို့မဟုတ် f-string ဖြစ်သည်။ f\"{name}: {score}\" တွင် braces အတွင်းရှိ expression တန်ဖိုးကို ထည့်သည်။\n\nint(\"95\") ဖြင့် စာသားမှ integer ပြောင်းနိုင်သော်လည်း int(\"Mya\") က ValueError ဖြစ်သည်။ int(12.9) သည် rounding လုပ်ခြင်း မဟုတ်ဘဲ decimal အပိုင်းကို ဖြတ်၍ 12 ဖြစ်သည်။ Float တွင် binary representation ကြောင့် ဒဿမအချို့ အတိအကျ မသိမ်းနိုင်ပါ။ ငွေကြေးအတွက် အနာဂတ်တွင် Decimal ကို လေ့လာပါ။",
      "lines":
          "၁။ name သည် string ဖြစ်သည်။\n၂။ score သည် integer ဖြစ်သည်။\n၃။ str(score) က \"95\" ပြောင်းပေးသဖြင့် string သုံးခုကို ဆက်နိုင်သည်။",
      "mistake":
          "\"Score: \" + 95 သည် TypeError ဖြစ်နိုင်သည်။ Number ကို string ပြောင်းပါ၊ သို့မဟုတ် print တွင် comma ခွဲပါ။",
      "hint":
          "price ကို quote မပါဘဲ 12.5 သတ်မှတ်ပြီး type(price) ကိုပါ စစ်ကြည့်ပါ။",
      "challenge":
          "price = 12.5 နှင့် quantity = 2 ကို သတ်မှတ်ပြီး total ကို တွက်ပါ။ Total: စာသားနှင့်အတူ ပြပါ။",
      "question": "\"2\" + \"3\" ၏ ရလဒ်သည် ဘာလဲ။",
      "explanation":
          "နှစ်ခုလုံး string ဖြစ်သောကြောင့် + က ဆက်ပေးပြီး \"23\" ဖြစ်သည်။",
    },
    en: {
      "objectives":
          "Identify str, int and float values; convert types deliberately.",
      "body":
          "\"95\" is text, 95 is an integer, and 12.5 is a floating-point number. Values that look similar can behave differently: \"2\" + \"3\" joins text into \"23\", whereas 2 + 3 adds numbers. Inspect a value with type(value).\n\nUse str(number) when joining a number to text. Alternatively, pass separate arguments to print or use an f-string, such as f\"{name}: {score}\". Expressions inside braces are evaluated and inserted into the text. Escape sequences such as \\n represent special characters inside strings.\n\nint(\"95\") converts valid integer text, but int(\"Mya\") raises ValueError. int(12.9) truncates toward zero; it does not round to the nearest integer. Floats represent many decimal fractions approximately. For precise financial arithmetic, study Decimal later rather than assuming every decimal is exact.",
      "lines":
          "1. name refers to text.\n2. score refers to an integer.\n3. str(score) produces \"95\", allowing three strings to be joined.",
      "mistake":
          "\"Score: \" + 95 mixes incompatible types. Convert the number or pass it as a separate print argument.",
      "hint":
          "Assign 12.5 without quotes; compare type(price) with type(\"12.5\").",
      "challenge":
          "Set price = 12.5 and quantity = 2, calculate total, and display it with a Total: label.",
      "question": "What is the result of \"2\" + \"3\"?",
      "explanation":
          "Both operands are strings, so + concatenates them into \"23\".",
    },
    myOptions: ["5", "\"23\"", "Error"],
    enOptions: ["5", "\"23\"", "Error"],
    correct: 1,
    reference: "https://docs.python.org/3/tutorial/introduction.html#strings",
  ),
  "py-04": LessonGuide(
    my: {
      "objectives":
          "stdin မှ input ဖတ်နိုင်ရန်။ input ရလဒ်ကို လိုအပ်သည့် type ပြောင်းရန်။",
      "body":
          "input(prompt) က prompt ကို ပြပြီး စာကြောင်းတစ်ကြောင်း ဖတ်သည်။ ပြန်ရသောတန်ဖိုးသည် string ဖြစ်သည်။ အသုံးပြုသူက 18 ရိုက်သော်လည်း int ပြောင်းမီ ကိန်းမဟုတ်သေးပါ။ name ကို လက်ခံ၊ နှုတ်ဆက်စာဆောက်၊ output ပြ ဟူသော data flow ကို အဆင့်လိုက် စဉ်းစားပါ။\n\nCode Lab ၏ standard input အကွက်တွင် program ဖတ်မည့်စာကြောင်းများကို Run မလုပ်မီ ထည့်ပါ။ input နှစ်ခါရှိလျှင် stdin တွင် စာကြောင်းနှစ်ကြောင်း လိုသည်။ Interactive terminal သကဲ့သို့ Run နောက်မှ စာရိုက်ပို့ခြင်း မဟုတ်ပါ။ input တစ်ခုအတွက် Mya ဟု ထည့်နိုင်ပြီး အသက်ကို နောက်လိုင်းတွင် 18 ထည့်နိုင်သည်။\n\nအသက်ကို တွက်မည်ဆိုလျှင် age = int(input(\"Age: \")) ရေးပြီး age + 1 တွက်ပါ။ Valid integer မဟုတ်လျှင် ValueError ဖြစ်မည်။ String တွင် .strip() ဖြင့် ဘေးနှစ်ဖက်က whitespace ဖယ်နိုင်သည်။ လိုအပ်သော input မရလျှင် EOFError ဖြစ်နိုင်သည်။ Error handling lesson တွင် invalid input ကို ကိုင်တွယ်မည်။ Password၊ API key တို့ကို လေ့ကျင့်ခန်း input ထဲ မထည့်ပါနှင့်။",
      "lines":
          "၁။ input က prompt ပြ၍ name စာသားကို လက်ခံသည်။\n၂။ \"Hello, \" နှင့် name ကို ဆက်၍ print ဖြင့် ပြသည်။",
      "mistake":
          "input() ရလဒ်ကို int မပြောင်းဘဲ 1 ပေါင်းလျှင် TypeError ဖြစ်နိုင်သည်။ stdin လိုင်းအရေအတွက် စစ်ပါ။",
      "hint": "age_text ကို input ဖတ်ပြီး age = int(age_text) ပြောင်းပါ။",
      "challenge":
          "အသက်ကို လက်ခံ၊ integer ပြောင်းပြီး နောက်နှစ်အသက်ကို ပြပါ။ stdin တွင် 18 ထည့်စမ်းပါ။",
      "question": "input() က မည်သည့် type ကို ပြန်ပေးလဲ။",
      "explanation":
          "input သည် နောက်ဆုံး newline ကို ဖယ်၍ string ပြန်ပေးသည်။ Type conversion ကို ကိုယ်တိုင် လုပ်ရသည်။",
    },
    en: {
      "objectives":
          "Read standard input; convert received text to the required type.",
      "body":
          "input(prompt) displays a prompt and reads one line. Its return value is a string, even when the user types digits. Trace the data flow: receive a name, construct a greeting, then print it.\n\nIn this app, put input lines in Code Lab’s standard input field before running. Two input calls need two lines. The sandbox receives prefilled input rather than an interactive terminal session. A name could be Mya on the first line and an age 18 on the second.\n\nTo calculate with an age, use age = int(input(\"Age: \")), then age + 1. Invalid integer text raises ValueError. The string method .strip() removes surrounding whitespace when needed. Missing input can raise EOFError. The error-handling lesson will show how to reject bad input. Use fictional data for practice and never include passwords or API keys in exercises.",
      "lines":
          "1. input displays the prompt and returns the entered name as text.\n2. Join the greeting to that text and print it.",
      "mistake":
          "Adding 1 directly to input() mixes a string and an integer. Also check that enough stdin lines were supplied.",
      "hint":
          "Read age_text first, convert it with int, then calculate the next age.",
      "challenge":
          "Read an age, convert it to an integer, and print the age next year. Try stdin 18.",
      "question": "What type does input() return?",
      "explanation":
          "input returns a string with the trailing newline removed. Numeric conversion is a separate step.",
    },
    myOptions: ["int", "str", "float"],
    enOptions: ["int", "str", "float"],
    correct: 1,
    reference: "https://docs.python.org/3/library/functions.html#input",
  ),
  "py-05": LessonGuide(
    my: {
      "objectives":
          "သင်္ချာ operator များနှင့် comparison များကို မှန်ကန်စွာ သုံးရန်။",
      "body":
          "Operator သည် တန်ဖိုးတစ်ခု သို့မဟုတ် နှစ်ခုအပေါ် အလုပ်လုပ်သည်။ +၊ -၊ *၊ / သည် ပေါင်း၊ နှုတ်၊ မြှောက်၊ စား ဖြစ်သည်။ Integer နှစ်ခုဖြစ်သော်လည်း / ရလဒ်သည် float ဖြစ်သည်။ 10 / 3 သည် ဒဿမအဖြေ၊ 10 // 3 သည် floor division 3၊ 10 % 3 သည် remainder 1 ဖြစ်သည်။ ** သည် power ဖြစ်ပြီး 2 ** 3 က 8 ဖြစ်သည်။\n\nလုပ်ဆောင်သည့်အစီအစဉ်ကို precedence ဟု ခေါ်သည်။ 2 + 3 * 4 က 14 ဖြစ်သည်။ (2 + 3) * 4 က 20 ဖြစ်သည်။ ရှင်းလင်းစေရန် parentheses ကို သုံးပါ။ // သည် အနုတ်ကိန်းတွင် သုညဆီ ဖြတ်ခြင်းမဟုတ်ပါ။ -7 // 3 သည် floor ဖြစ်သော -3 ဖြစ်သည်။\n\n==၊ !=၊ <၊ <=၊ >၊ >= comparison များက True သို့ False ပြန်ပေးသည်။ and၊ or၊ not ဖြင့် condition ဆက်နိုင်သည်။ age >= 18 and has_ticket သည် နှစ်ခုလုံး မှန်ရန်လိုသည်။ x += 1 သည် x = x + 1 ကို အတိုရေးခြင်း ဖြစ်သည်။ Zero ဖြင့် စားမိလျှင် ZeroDivisionError ဖြစ်သည်။",
      "lines":
          "၁။ a = 10 နှင့် b = 3 တန်ဖိုးများ သတ်မှတ်သည်။\n၂။ print(a + b) က 13 ကို မျှော်မှန်းသည်။\n၃။ print(a % b) က အကြွင်း 1 ကို မျှော်မှန်းသည်။",
      "mistake":
          "= နှင့် == မရောပါနှင့်။ // ၏ negative floor behavior ကို စမ်းကြည့်ပါ။",
      "hint":
          "% ကို အသုံးပြုပါ။ 12 ကို 5 နှစ်ကြိမ်စားပြီး ကျန်သည့် ပမာဏကို စဉ်းစားပါ။",
      "challenge":
          "12 % 5 ကို ပြပါ။ ကိန်းတစ်ခု စုံ/မစုံ စစ်ရန် n % 2 == 0 ကိုပါ စမ်းပါ။",
      "question": "2 + 3 * 4 ၏ ရလဒ်သည် ဘာလဲ။",
      "explanation":
          "မြှောက်ခြင်း အရင်လုပ်သောကြောင့် 3 * 4 = 12 ပြီး 2 ပေါင်း၍ 14 ဖြစ်သည်။",
    },
    en: {
      "objectives":
          "Use arithmetic operators and comparisons with correct precedence.",
      "body":
          "Operators perform actions on values. +, -, *, and / add, subtract, multiply, and divide. Division with / returns a float even when both operands are integers. For 10 and 3, // yields the floor quotient 3 and % yields the remainder 1. ** raises to a power: 2 ** 3 is 8.\n\nPrecedence controls evaluation order. 2 + 3 * 4 is 14; (2 + 3) * 4 is 20. Use parentheses to clarify intent. Floor division is not truncation toward zero: -7 // 3 is -3.\n\nComparisons such as ==, !=, <, <=, >, and >= return Boolean values. Combine conditions with and, or, and not. age >= 18 and has_ticket requires both conditions to hold. The statement x += 1 is a concise increment. Dividing by zero raises ZeroDivisionError; plan what should happen before performing that operation.",
      "lines":
          "1. Assign the operands a = 10 and b = 3.\n2. Print their sum, expected to be 13.\n3. Print the remainder, expected to be 1.",
      "mistake":
          "Do not confuse assignment = with comparison ==. Check floor behavior for negative values.",
      "hint": "Use % to find what remains after removing groups of five.",
      "challenge": "Print 12 % 5. Then test whether n is even with n % 2 == 0.",
      "question": "What is 2 + 3 * 4?",
      "explanation":
          "Multiplication happens first: 3 * 4 is 12, then adding 2 gives 14.",
    },
    myOptions: ["20", "14", "24"],
    enOptions: ["20", "14", "24"],
    correct: 1,
    reference: "https://docs.python.org/3/tutorial/introduction.html#numbers",
  ),
  "py-06": LessonGuide(
    my: {
      "objectives":
          "if၊ elif၊ else branch များနှင့် indentation ကို နားလည်ရန်။",
      "body":
          "အခြေအနေအလိုက် လုပ်ဆောင်ချက်ရွေးရသောအခါ if ကို သုံးသည်။ ဥပမာ အသက် 18 နှစ်နှင့်အထက်ဆို Adult၊ မဟုတ်လျှင် Minor ပြရန် condition စစ်မည်။ if header အဆုံးတွင် colon ပါရသည်။ အောက်က block ကို တူညီသောနေရာလွတ်ဖြင့် indent လုပ်ပါ။ ပုံမှန်အားဖြင့် space ၄ ခု သုံးသည်။\n\nCondition ကို အရင်စစ်ပြီး မှန်လျှင် ပထမ block တစ်ခုတည်း လုပ်သည်။ မမှန်လျှင် else block လုပ်သည်။ အခြေအနေများစွာရှိပါက elif ထည့်နိုင်သည်။ score >= 80 ကို ပထမ၊ score >= 50 ကို ဒုတိယစစ်လျှင် Grade A၊ Pass၊ Fail ဟူ၍ ခွဲနိုင်သည်။ if/elif chain တွင် ပထမဆုံး မှန်သော branch တစ်ခုသာ လုပ်သည်။\n\nBoundary ကို စမ်းပါ။ age = 17၊ 18၊ 19 အတွက် ဘယ် branch ဝင်မည်လဲ စဉ်းစားပါ။ >= နှင့် > ၏ ကွာခြားချက်ကို ရလဒ်ဖြင့် မြင်နိုင်သည်။ Condition များကို လွတ်လပ်သော if များဖြင့် ရေးလျှင် branch အများကြီး လုပ်နိုင်သဖြင့် elif နှင့် မတူပါ။",
      "lines":
          "၁။ age = 20 သတ်မှတ်သည်။\n၂။ age >= 18 သည် True ဖြစ်သည်။\n၃။ Adult ကို ပြပြီး else ကို ကျော်သည်။\n၄။ age ကို 16 ပြောင်းလျှင် Minor branch လုပ်သည်။",
      "mistake":
          "Colon ပျောက်ခြင်း၊ tabs နှင့် spaces ရောခြင်း၊ >= အစား > သုံးခြင်းတို့ကို စစ်ပါ။",
      "hint":
          "score = 60 ကို သတ်မှတ်ပြီး if score >= 50: အောက်တွင် print ကို indent လုပ်ပါ။",
      "challenge":
          "score ကို စစ်၍ 80 နှင့်အထက် A၊ 50 နှင့်အထက် Pass၊ ကျန်လျှင် Fail ပြပါ။ 49၊ 50၊ 80 ကို စမ်းပါ။",
      "question": "age = 18 နှင့် if age >= 18 တွင် ဘယ် branch လုပ်မလဲ။",
      "explanation":
          ">= တွင် equality ပါသောကြောင့် condition မှန်ပြီး if branch လုပ်မည်။",
    },
    en: {
      "objectives":
          "Choose branches with if, elif and else; indent blocks correctly.",
      "body":
          "Use if when behavior depends on a condition. For example, display Adult for an age of at least 18 and Minor otherwise. End the header with a colon and indent its block consistently, conventionally with four spaces.\n\nPython checks the condition first. If it is true, the if block runs; otherwise the else block runs. Add elif for more cases. Checking score >= 80 before score >= 50 can distinguish A, Pass, and Fail. An if/elif chain executes the first matching branch only. Order therefore matters.\n\nTest boundary values, not just obvious examples. For an age threshold of 18, inspect 17, 18 and 19. The difference between > and >= appears exactly at the threshold. Several independent if statements can all execute, unlike a single if/elif chain. Choose the structure that expresses your requirement.",
      "lines":
          "1. Set age to 20.\n2. age >= 18 evaluates to True.\n3. Print Adult and skip the else block.\n4. Changing age to 16 selects Minor instead.",
      "mistake":
          "Check for a missing colon, mixed tabs/spaces, or a strict > where >= was required.",
      "hint":
          "Assign score first; indent the print statement under if score >= 50:.",
      "challenge":
          "Display A for 80 or above, Pass for 50 or above, otherwise Fail. Test 49, 50 and 80.",
      "question": "For age = 18, which branch does if age >= 18 select?",
      "explanation": ">= includes equality, so the if branch executes.",
    },
    myOptions: ["if", "else", "နှစ်ခုလုံး"],
    enOptions: ["if", "else", "Both"],
    correct: 0,
    reference:
        "https://docs.python.org/3/tutorial/controlflow.html#if-statements",
  ),
  "py-07": LessonGuide(
    my: {
      "objectives":
          "Sequence ကို for ဖြင့် iterate လုပ်ရန်။ range ၏ stop boundary သိရန်။",
      "body":
          "for loop သည် collection မှ တန်ဖိုးတစ်ခုချင်းကို variable ထဲ ချိတ်ပြီး block ကို လုပ်သည်။ လူနာမည် list အတွင်း တစ်ယောက်ချင်း နှုတ်ဆက်ခြင်း၊ ဈေးနှုန်းစုစုပေါင်းတွက်ခြင်းတို့တွင် သုံးနိုင်သည်။ Loop variable ကို number ဟု မဖြစ်မနေ နာမည်ပေးရန် မလိုပါ။ ရှင်းလင်းသောနာမည် ရွေးပါ။\n\nrange(5) သည် 0၊ 1၊ 2၊ 3၊ 4 ကို ပေးသည်။ stop တန်ဖိုး 5 မပါပါ။ range(1, 6) သည် 1 မှ 5 ထိ ဖြစ်သည်။ range(2, 10, 2) တွင် step 2 ကြောင့် 2၊ 4၊ 6၊ 8 ရမည်။ range ကို အကုန် list မဆောက်ဘဲ loop အတွင်း သုံးနိုင်သည်။\n\nပေါင်းလဒ်တွက်မည်ဆို total = 0 ကို loop မဝင်မီ သတ်မှတ်ပြီး total += number ကို အတွင်းရေးပါ။ total = 0 ကို အတွင်းရေးမိလျှင် တစ်ခါတိုင်း ပြန်စမည်။ break က loop ကို ရပ်ပြီး continue က ယခု iteration ကျန်သည့် code ကို ကျော်သည်။ ပထမဆုံး range boundary ကို စာရွက်ပေါ် trace လုပ်ပြီး နောက်မှ စမ်းပါ။",
      "lines":
          "၁။ range(5) က stop မပါသော ကိန်းအစဉ် ပေးသည်။\n၂။ number ထဲ 0၊ 1၊ 2၊ 3၊ 4 ကို အလှည့်ကျ ချိတ်သည်။\n၃။ indented print က တန်ဖိုးတစ်ခုချင်းကို ပြသည်။",
      "mistake":
          "range(1, 5) သည် 5 မပါပါ။ စုစုပေါင်း variable ကို loop အတွင်း ပြန် reset မလုပ်ပါနှင့်။",
      "hint": "1 မှ 5 ထိ ဆို start ကို 1၊ stop ကို 6 ထားပါ။",
      "challenge":
          "1 မှ 5 ထိ ပြပြီး စုစုပေါင်းကို loop ဖြင့် တွက်ပါ။ မျှော်မှန်း sum သည် 15 ဖြစ်သည်။",
      "question": "range(1, 4) တွင် ဘယ်ကိန်းတွေ ပါလဲ။",
      "explanation": "start ပါပြီး stop မပါသဖြင့် 1၊ 2၊ 3 ပါသည်။",
    },
    en: {
      "objectives":
          "Iterate over a sequence; understand the exclusive range stop.",
      "body":
          "A for loop binds each item from an iterable to a variable and executes its block. Use it to greet names in a list or add prices. Choose a meaningful loop-variable name; number is just one example.\n\nrange(5) provides 0, 1, 2, 3, 4, excluding the stop value 5. range(1, 6) gives 1 through 5. With a step of two, range(2, 10, 2) gives 2, 4, 6, 8. You can iterate over a range without building a list of every value first.\n\nFor a running total, assign total = 0 before the loop, then put total += number inside it. Resetting total inside the block would erase earlier work each time. break exits a loop; continue skips the rest of the current iteration. Trace a small range on paper to check boundaries before running the code.",
      "lines":
          "1. range(5) supplies integers before its exclusive stop.\n2. number is bound successively to 0 through 4.\n3. The indented print runs once for each value.",
      "mistake":
          "range(1, 5) excludes 5. Do not reset an accumulator inside the loop.",
      "hint": "For 1 through 5, use start 1 and stop 6.",
      "challenge":
          "Print 1 through 5 and calculate their sum using a loop. The expected sum is 15.",
      "question": "Which values are in range(1, 4)?",
      "explanation": "The start is included and stop excluded, giving 1, 2, 3.",
    },
    myOptions: ["1, 2, 3", "1, 2, 3, 4", "0, 1, 2, 3"],
    enOptions: ["1, 2, 3", "1, 2, 3, 4", "0, 1, 2, 3"],
    correct: 0,
    reference:
        "https://docs.python.org/3/tutorial/controlflow.html#the-range-function",
  ),
  "py-08": LessonGuide(
    my: {
      "objectives":
          "while condition စစ်သည့်အစီအစဉ်နှင့် termination ကို ရှင်းပြနိုင်ရန်။",
      "body":
          "Iteration အရေအတွက် ကြိုမသိလျှင် while ကို သုံးနိုင်သည်။ Condition ကို block မဝင်မီ စစ်သည်။ True ဖြစ်လျှင် block လုပ်၊ condition ပြန်စစ်၊ False ဖြစ်မှ ရပ်သည်။ စစချင်း False ဖြစ်လျှင် တစ်ကြိမ်မျှ မလုပ်ပါ။\n\nနမူနာတွင် count သည် 1 မှ စသည်။ 1 <= 3 မှန်၍ 1 ကို ပြပြီး count ကို 2 ပြောင်းသည်။ 2၊ 3 အတွက် ဆက်လုပ်ပြီး 4 <= 3 မမှန်သည့်အခါ ရပ်သည်။ Update စာကြောင်းသည် loop အတွင်း ရှိရမည်။ အပြင်ရောက်နေလျှင် condition မပြောင်းဘဲ infinite loop ဖြစ်မည်။ Sandbox က timeout ဖြင့် ရပ်နိုင်သော်လည်း မှန်ကန်သော logic အစားထိုးခြင်း မဟုတ်ပါ။\n\nရပ်မည့်အကြောင်းရင်းကို စဉ်းစားပါ။ Countdown တွင် count -= 1၊ attempts limit တွင် attempts += 1 လိုသည်။ Retry loop တွင် invalid input ရလာသည့် path မှာလည်း attempts တိုးမတိုး စစ်ပါ။ Known finite collection ကို လှည့်မည်ဆို for က ပိုရှင်းလင်းတတ်သည်။",
      "lines":
          "၁။ count ကို 1 စတင်သည်။\n၂။ count <= 3 condition ကို အကြိမ်တိုင်း စစ်သည်။\n၃။ count ကို ပြသည်။\n၄။ count += 1 ဖြင့် တစ်ခုတိုး၍ ရပ်နိုင်စေသည်။",
      "mistake":
          "count += 1 ပျောက်လျှင် loop မရပ်နိုင်ပါ။ <= အစား < သုံးလျှင် နောက်ဆုံးတန်ဖိုး မပါနိုင်ပါ။",
      "hint":
          "စတင်တန်ဖိုး၊ ဆက်လုပ်မည့် condition၊ တန်ဖိုးပြောင်းသည့် update သုံးခု စစ်ပါ။",
      "challenge":
          "while ဖြင့် 5 မှ 1 ထိ countdown ပြပြီး အဆုံးတွင် Done ပြပါ။",
      "question": "while False: အောက်က block သည် ဘယ်နှကြိမ် လုပ်မလဲ။",
      "explanation":
          "while က အရင် condition စစ်သောကြောင့် False ဆို block မဝင်ပါ။",
    },
    en: {
      "objectives": "Trace while evaluation and explain how a loop terminates.",
      "body":
          "Use while when the number of iterations depends on a condition. Python checks the condition before entering the block. If true, it runs the block and checks again; false ends the loop. An initially false condition means zero iterations.\n\nIn the example, count begins at 1. After printing 1, the increment makes it 2. The loop prints 2 and 3, then stops when 4 <= 3 is false. The update must be inside the block. Without it, the condition never changes and the loop may be infinite. A sandbox timeout can stop runaway code, but it is not a replacement for correct logic.\n\nIdentify a concrete termination reason. A countdown needs a decrement; an attempt limit needs an increment on each relevant path. In a retry loop, check whether invalid input still advances the attempt count. For a known finite collection, a for loop is often easier to read.",
      "lines":
          "1. Initialize count to 1.\n2. Check count <= 3 before each iteration.\n3. Print the current value.\n4. Increment it so the condition eventually becomes false.",
      "mistake":
          "A missing update may prevent termination. A strict < can exclude the intended last value.",
      "hint":
          "Check initialization, continuation condition, and update separately.",
      "challenge": "Count down from 5 to 1 using while, then print Done.",
      "question": "How many times does the block under while False: execute?",
      "explanation":
          "The condition is tested first and is already false, so there are zero iterations.",
    },
    myOptions: ["0", "1", "အဆုံးမရှိ"],
    enOptions: ["0", "1", "Forever"],
    correct: 0,
    reference:
        "https://docs.python.org/3/reference/compound_stmts.html#the-while-statement",
  ),
  "py-09": LessonGuide(
    my: {
      "objectives":
          "List တည်ဆောက်၊ index ဖြင့် ဖတ်၊ append ဖြင့် ပြင်နိုင်ရန်။",
      "body":
          "List သည် တန်ဖိုးများကို အစဉ်လိုက် သိမ်းသော mutable collection ဖြစ်သည်။ fruits = [\"apple\", \"mango\"] တွင် item နှစ်ခု ပါသည်။ fruits[0] က apple ဖြစ်ပြီး fruits[1] က mango ဖြစ်သည်။ len(fruits) က 2 ဖြစ်သည်။ နောက်ဆုံး item ကို fruits[-1] ဖြင့်လည်း ဖတ်နိုင်သည်။\n\nappend(\"banana\") သည် list အဆုံးတွင် item ထည့်ပြီး မူရင်း list ကို ပြောင်းသည်။ Return သည် None ဖြစ်သဖြင့် fruits = fruits.append(...) ဟု မရေးပါနှင့်။ fruits[0] = \"orange\" ဖြင့် item တစ်ခု အစားထိုးနိုင်သည်။ pop() သည် နောက်ဆုံး item ကို ဖယ်ပြီး ပြန်ပေးသည်။ Empty list တွင် pop လုပ်ခြင်း သို့မဟုတ် မရှိသော index ဖတ်ခြင်းက IndexError ဖြစ်နိုင်သည်။\n\nfruits[:2] သည် ပထမနှစ်ခု၏ list အသစ် ဖြစ်သည်။ backup = fruits ဆိုလျှင် မိတ္တူမဟုတ်ဘဲ list တစ်ခုတည်းကို နာမည်နှစ်ခု ရည်ညွှန်းခြင်း ဖြစ်သည်။ Shallow copy လိုလျှင် fruits.copy() သုံးနိုင်သည်။ Loop လုပ်နေစဉ် မူရင်း list ကို မဆင်ခြင်ဘဲ ပြင်လျှင် item များ ကျော်သွားနိုင်သည်။",
      "lines":
          "၁။ fruits list တွင် apple၊ mango သိမ်းသည်။\n၂။ append က banana ထပ်ထည့်သည်။\n၃။ for က item သုံးခုကို တစ်ခုချင်း ဖတ်သည်။\n၄။ print က ယခု fruit ကို ပြသည်။",
      "mistake":
          "Index က 0 မှ စသည်။ append ရလဒ်ကို list variable ထဲ ပြန်မသတ်မှတ်ပါနှင့်။",
      "hint": "Square brackets အတွင်း string သုံးခုကို comma ခွဲရေးပါ။",
      "challenge":
          "အရောင်သုံးခု list ဆောက်၊ အရောင်တစ်ခု append လုပ်၊ ပထမ item နှင့် length ကို ပြပါ။",
      "question": "items = [\"a\", \"b\"] တွင် items[0] သည် ဘာလဲ။",
      "explanation":
          "Python list index သည် 0 မှ စသောကြောင့် ပထမ item \"a\" ကို ရသည်။",
    },
    en: {
      "objectives": "Create lists, read by index, and mutate them with append.",
      "body":
          "A list is an ordered, mutable collection. In fruits = [\"apple\", \"mango\"], fruits[0] is apple and fruits[1] is mango. len(fruits) is 2, and fruits[-1] reads the last item.\n\nappend(\"banana\") changes the existing list by adding an item at its end. Its return value is None, so do not assign fruits = fruits.append(...). You can replace an item with fruits[0] = \"orange\". pop() removes and returns the last item. Reading an invalid index or popping an empty list can raise IndexError.\n\nThe slice fruits[:2] produces a new list with the first two items. In contrast, backup = fruits gives the same list a second name; it does not copy it. Use fruits.copy() for a shallow copy when appropriate. Mutating a collection while iterating over it can skip items and create subtle bugs. Prefer building a new result list when learning filtering.",
      "lines":
          "1. Create a list containing apple and mango.\n2. Append banana to that list.\n3. Iterate over its three items.\n4. Print the current fruit.",
      "mistake":
          "Indices start at zero. append returns None rather than the updated list.",
      "hint":
          "Put three quoted colors inside square brackets, separated by commas.",
      "challenge":
          "Create three colors, append another, and display the first item and list length.",
      "question": "For items = [\"a\", \"b\"], what is items[0]?",
      "explanation":
          "Indices start at zero, so index 0 reads the first item \"a\".",
    },
    myOptions: ["\"a\"", "\"b\"", "2"],
    enOptions: ["\"a\"", "\"b\"", "2"],
    correct: 0,
    reference:
        "https://docs.python.org/3/tutorial/datastructures.html#more-on-lists",
  ),
  "py-10": LessonGuide(
    my: {
      "objectives":
          "Function သတ်မှတ်၊ argument ပို့၊ return တန်ဖိုး ပြန်ယူနိုင်ရန်။",
      "body":
          "Function သည် အလုပ်တစ်ခုကို နာမည်ပေးပြီး ထပ်ခါတလဲလဲ ခေါ်နိုင်သော code block ဖြစ်သည်။ def greet(name): တွင် greet က function နာမည်၊ name က parameter ဖြစ်သည်။ greet(\"Mya\") တွင် \"Mya\" က argument ဖြစ်သည်။ Definition ရေးရုံဖြင့် body ကို မလုပ်သေးပါ။ ခေါ်သည့်အခါမှ လုပ်သည်။\n\nreturn သည် function မှ တန်ဖိုးပြန်ပေးပြီး ယခု call ကို အဆုံးသတ်သည်။ print သည် output ပြသခြင်းဖြစ်ပြီး return ကို အစားမထိုးပါ။ Function က greeting ကို return လုပ်လျှင် result = greet(\"Mya\") ဖြင့် သိမ်းနိုင်ပြီး print(result) ဖြင့် ပြနိုင်သည်။ Explicit return မရှိလျှင် None ပြန်သည်။\n\nParameter သို့ function အတွင်း သတ်မှတ်သောနာမည်များသည် local scope တွင် ရှိသည်။ Function အပြင်ကနေ local နာမည်ကို တိုက်ရိုက် မဖတ်နိုင်ပါ။ Input ကို parameter ဖြင့် ပို့ပြီး output ကို return ဖြင့် ပြန်ယူသော function သည် စမ်းသပ်ရန် ပိုလွယ်သည်။ add(2, 3)၊ add(0, 0)၊ add(-2, 2) ကဲ့သို့ နမူနာများဖြင့် behavior စစ်ပါ။",
      "lines":
          "၁။ def က greet function နှင့် name parameter ကို သတ်မှတ်သည်။\n၂။ return က greeting စာသား ပြန်ပေးသည်။\n၃။ blank line သည် readability အတွက်သာ ဖြစ်သည်။\n၄။ greet(\"Mya\") ခေါ်၊ ပြန်လာသည့်စာသားကို print ပြသည်။",
      "mistake":
          "Function ကို ခေါ်မီ သတ်မှတ်ပါ။ print သာရှိပြီး return မရှိလျှင် ရလဒ်ကို variable ထဲ သိမ်းရာတွင် None ရမည်။",
      "hint": "def add(a, b): အောက်တွင် return a + b ကို indent လုပ်ပါ။",
      "challenge":
          "add(a, b) function ရေး၍ positive၊ zero၊ negative argument များဖြင့် သုံးကြိမ် ခေါ်ပါ။",
      "question": "Explicit return မရှိသော function သည် ဘာကို ပြန်ပေးလဲ။",
      "explanation":
          "Python သည် function အဆုံးရောက်ပြီး return မတွေ့လျှင် None ပြန်ပေးသည်။",
    },
    en: {
      "objectives":
          "Define functions, pass arguments, and use returned values.",
      "body":
          "A function gives a reusable block of work a name. In def greet(name):, greet is the function name and name is a parameter. In greet(\"Mya\"), \"Mya\" is an argument. Defining a function does not run its body; calling it does.\n\nreturn sends a value back to the caller and ends the current call. print displays output and does not replace return. A greeting returned by a function can be stored with result = greet(\"Mya\") and displayed later. With no explicit return, a function returns None.\n\nParameters and names assigned inside a function usually belong to its local scope. You cannot read those local names directly from outside. Functions with explicit inputs and returned outputs are easier to test than functions relying on changing global state. Check behavior with cases such as add(2, 3), add(0, 0), and add(-2, 2), including boundaries and negative values.",
      "lines":
          "1. Define greet with a name parameter.\n2. Return a constructed greeting.\n3. The blank line improves readability.\n4. Call greet(\"Mya\") and print its returned value.",
      "mistake":
          "Define the function before calling it. A function that only prints still returns None unless it explicitly returns something.",
      "hint": "Indent return a + b beneath def add(a, b):.",
      "challenge":
          "Write add(a, b) and call it with positive, zero and negative arguments.",
      "question": "What does a function with no explicit return value return?",
      "explanation":
          "When the function reaches its end without an explicit return, Python returns None.",
    },
    myOptions: ["0", "None", "True"],
    enOptions: ["0", "None", "True"],
    correct: 1,
    reference:
        "https://docs.python.org/3/tutorial/controlflow.html#defining-functions",
  ),
  "py-11": LessonGuide(
    my: {
      "objectives":
          "Dictionary key/value ဖြင့် မှတ်တမ်းသိမ်းရန်။ Missing key ကို get ဖြင့် ကိုင်တွယ်ရန်။",
      "body":
          "List သည် position ဖြင့် ဖတ်သော်လည်း dictionary သည် key ဖြင့် တန်ဖိုး ရှာသည်။ Student မှတ်တမ်းအတွက် name နှင့် score ဟူသော label များဖြင့် သိမ်းလျှင် list index မမှတ်ရတော့ပါ။ Braces အတွင်း key: value pair များကို comma ခွဲရေးသည်။ Key များသည် unique ဖြစ်ရပြီး string၊ integer ကဲ့သို့ hashable type ဖြစ်ရသည်။ List ကို key အဖြစ် မသုံးနိုင်ပါ။\n\nstudent[\"name\"] က name value ဖတ်သည်။ student[\"score\"] = 90 ဖြင့် update လုပ်နိုင်ပြီး key အသစ်ဆို ထည့်ပေးသည်။ မရှိသော key ကို [] ဖြင့် ဖတ်လျှင် KeyError ဖြစ်သည်။ student.get(\"city\", \"Unknown\") က city မရှိလျှင် default ကို ပြန်ပေးသည်။ get သည် default ကို dictionary ထဲ ထည့်ပေးခြင်း မဟုတ်ပါ။\n\nfor key, value in student.items(): ဖြင့် pair တစ်ခုချင်း ဖတ်နိုင်သည်။ Python dictionary က insertion order ကို ထိန်းသည်။ Key တစ်ခုကို ထပ်မံ assign လုပ်လျှင် value အသစ်က အဟောင်းကို အစားထိုးသည်။ Country မှ capital၊ product မှ price၊ lesson ID မှ completed status ကဲ့သို့ lookup လုပ်ရာတွင် အသုံးဝင်သည်။",
      "lines":
          "၁။ student dictionary ထဲ name နှင့် score pair များ သိမ်းသည်။\n၂။ name key ၏ value ကို ဖတ်၍ ပြသည်။\n၃။ မရှိသော city key အတွက် Unknown default ပြသည်။",
      "mistake":
          "String key တွင် quotes လိုသည်။ Dictionary ကို list index သကဲ့သို့ 0 ဖြင့် ဖတ်လျှင် ထို key မရှိနိုင်ပါ။",
      "hint":
          "profile = {\"name\": \"Mya\", \"city\": \"Yangon\"} မှ စတင်ပြီး profile[\"city\"] ကို ပြင်ပါ။",
      "challenge":
          "name၊ city ပါသော profile dictionary ရေး၊ city ကို ပြင်ပြီး မရှိသော email ကို get ဖြင့် Not provided ပြပါ။",
      "question": "d = {\"a\": 1} ဖြစ်လျှင် d.get(\"b\", 0) သည် ဘာလဲ။",
      "explanation":
          "b key မရှိသောကြောင့် default 0 ပြန်ပေးပြီး d ကို မပြောင်းပါ။",
    },
    en: {
      "objectives":
          "Store records as key/value pairs; handle missing keys with get.",
      "body":
          "Lists locate values by position, while dictionaries locate values by key. A student record with name and score labels is easier to understand than remembering list indices. Write key: value pairs inside braces, separated by commas. Keys are unique and must be hashable, such as strings or integers; lists cannot be keys.\n\nstudent[\"name\"] reads a value. Assigning student[\"score\"] = 90 updates it, or adds the key if absent. Reading an absent key with brackets raises KeyError. student.get(\"city\", \"Unknown\") instead returns the default when city is missing. get does not insert that default into the dictionary.\n\nIterate over pairs with for key, value in student.items():. Dictionaries preserve insertion order. Assigning an existing key replaces its old value. Useful applications include countries mapped to capitals, products mapped to prices, and lesson IDs mapped to completion states. Keep sensitive account data out of practice records.",
      "lines":
          "1. Create a student record with name and score keys.\n2. Read and print the value for name.\n3. Return Unknown for the absent city key.",
      "mistake":
          "String keys need quotes. Reading index 0 does not mean the first item unless 0 is an actual key.",
      "hint":
          "Start with name and city pairs, then assign a new value to profile[\"city\"].",
      "challenge":
          "Build a profile with name and city, update city, and use get to display Not provided for a missing email.",
      "question": "For d = {\"a\": 1}, what does d.get(\"b\", 0) return?",
      "explanation":
          "The missing b key causes get to return its default 0 without changing d.",
    },
    myOptions: ["1", "0", "KeyError"],
    enOptions: ["1", "0", "KeyError"],
    correct: 1,
    reference:
        "https://docs.python.org/3/tutorial/datastructures.html#dictionaries",
  ),
  "py-12": LessonGuide(
    my: {
      "objectives":
          "Syntax error နှင့် exception ခွဲခြားရန်။ ValueError ကို သတ်သတ်မှတ်မှတ် catch လုပ်ရန်။",
      "body":
          "Code ရေးသားပုံ ပျက်နေလျှင် syntax error ဖြစ်သည်။ Syntax မှန်သော်လည်း Run အတွင်း မလုပ်နိုင်သည့်အခြေအနေ ရှိလျှင် exception ဖြစ်သည်။ int(\"hello\") က ValueError၊ 1 / 0 က ZeroDivisionError ဖြစ်သည်။ Traceback တွင် file၊ line နှင့် exception နာမည်ကို ဖတ်ပြီး မိမိပြင်နိုင်သော ပထမဆုံးအကြောင်းရင်း ရှာပါ။\n\ntry အတွင်း အမှားဖြစ်နိုင်သော အလုပ်တစ်ခုကို ထည့်ပြီး except ValueError: ဖြင့် သက်ဆိုင်ရာအမှားကို ကိုင်တွယ်ပါ။ နမူနာတွင် valid integer ရလျှင် နောက်နှစ်အသက် ပြပြီး invalid text ဆို ရှင်းလင်းသော message ပြသည်။ except branch က ရလဒ်အောင်မြင်ကြောင်း အတုမပြရပါ။ အသုံးပြုသူ ပြန်ကြိုးစားနိုင်စေရန် လမ်းညွှန်ပါ။\n\nException အားလုံးကို bare except ဖြင့် ဖုံးကွယ်ခြင်းက bug နှင့် cancel အချက်ပြများကိုပါ ဖမ်းနိုင်သည်။ မျှော်လင့်ထားသော type ကိုသာ catch လုပ်ပြီး try block ကို သေးအောင်ထားပါ။ finally သည် success သို့ failure နှစ်မျိုးလုံးတွင် cleanup အတွက် လုပ်သည်။ Valid input၊ invalid text၊ negative age၊ input ပျောက်သည့် case များသည် မတူသော requirement များဖြစ်သည်။ ValueError catch လုပ်ထားရုံဖြင့် အားလုံးကို ကာကွယ်ပြီး မဟုတ်ပါ။",
      "lines":
          "၁။ try က integer ပြောင်းမှုကို စောင့်ကြည့်သည်။\n၂။ input စာသားကို int ပြောင်းပြီး age ထဲ ချိတ်သည်။\n၃။ အောင်မြင်လျှင် age + 1 ကို ပြသည်။\n၄။ ValueError ဖြစ်လျှင် except branch ဝင်ပြီး valid integer တောင်းသည်။",
      "mistake":
          "Error ကို ဖမ်းပြီး pass သာရေးလျှင် ဘာမှမလုပ်သလို ဖြစ်နိုင်သည်။ EOFError နှင့် negative value validation ကို သီးခြား စဉ်းစားပါ။",
      "hint":
          "int(input(...)) ကို try ထဲ ထည့်ပြီး except ValueError အောက်တွင် message ပြပါ။",
      "challenge":
          "အသက် input ကို try/except ဖြင့် ဖတ်ပါ။ Invalid text အတွက် message ပြပြီး negative age ကို if ဖြင့် ပယ်ချပါ။",
      "question": "int(\"hello\") က မည်သည့် exception ဖြစ်စေလဲ။",
      "explanation":
          "String သည် integer ပုံစံမဟုတ်သောကြောင့် ValueError ဖြစ်သည်။",
    },
    en: {
      "objectives":
          "Distinguish syntax errors from exceptions; catch ValueError specifically.",
      "body":
          "A syntax error means the source cannot be parsed as valid Python. An exception occurs when valid code encounters a problem during execution. int(\"hello\") raises ValueError, while 1 / 0 raises ZeroDivisionError. Read the traceback’s file, line, and exception name to find the cause you can correct.\n\nPut an operation that may fail inside try and handle the expected type with except ValueError:. In this example, valid integer input displays next year’s age; invalid text displays a helpful message. The failure branch should never report a fabricated successful result. Tell the learner how to correct the input.\n\nA bare except can hide programming mistakes and intercept cancellation signals. Catch specific expected types and keep the try block small. finally runs for cleanup on both success and failure. Valid input, invalid text, negative ages, and missing input represent different cases. Catching ValueError alone does not address all of them: negative age needs validation and absent stdin can raise EOFError.",
      "lines":
          "1. Start a try block around conversion.\n2. Read text and convert it with int.\n3. On success, print age + 1.\n4. On ValueError, run the handler asking for a valid integer.",
      "mistake":
          "Catching an error and doing nothing hides failures. Consider EOFError and negative-value validation separately.",
      "hint":
          "Put int(input(...)) in try and display a clear message under except ValueError:.",
      "challenge":
          "Read an age with try/except. Handle invalid text and reject negative ages with if.",
      "question": "Which exception does int(\"hello\") raise?",
      "explanation":
          "The text cannot be parsed as an integer, so conversion raises ValueError.",
    },
    myOptions: ["NameError", "ValueError", "ZeroDivisionError"],
    enOptions: ["NameError", "ValueError", "ZeroDivisionError"],
    correct: 1,
    reference: "https://docs.python.org/3/tutorial/errors.html",
  ),
};
