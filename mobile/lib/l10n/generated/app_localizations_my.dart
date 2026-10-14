// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get home => 'မူလ';

  @override
  String get learn => 'သင်ခန်းစာ';

  @override
  String get profile => 'ပရိုဖိုင်';

  @override
  String get signIn => 'အကောင့်ဝင်ရန်';

  @override
  String get signUp => 'အကောင့်ဖွင့်ရန်';

  @override
  String get signOut => 'အကောင့်ထွက်ရန်';

  @override
  String get email => 'အီးမေးလ်';

  @override
  String get password => 'စကားဝှက်';

  @override
  String get wait => 'ခဏစောင့်ပါ…';

  @override
  String get authInvalid =>
      'အီးမေးလ်မှန်ကန်စွာနှင့် စကားဝှက် အနည်းဆုံး ၈ လုံး ထည့်ပါ။';

  @override
  String get authFailed =>
      'အကောင့်ဝင်မရပါ။ အချက်အလက်၊ အီးမေးလ်အတည်ပြုမှုနှင့် အင်တာနက်ကို စစ်ပါ။';

  @override
  String get checkEmail =>
      'အတည်ပြုရန် သို့မဟုတ် စကားဝှက်ပြန်သတ်မှတ်ရန် အီးမေးလ်ကို စစ်ပါ။';

  @override
  String get forgotPassword => 'စကားဝှက်မေ့နေပါသလား။';

  @override
  String get updatePassword => 'စကားဝှက်အသစ် သတ်မှတ်ရန်';

  @override
  String get passwordUpdated => 'စကားဝှက် ပြောင်းပြီးပါပြီ။';

  @override
  String get switchAuth => 'အကောင့်ဝင်ရန် / ဖွင့်ရန် ပြောင်းမည်';

  @override
  String get guest => 'ဧည့်သည်အဖြစ် လေ့လာနေသည်';

  @override
  String get cloudNotice =>
      'Guest သင်ခန်းစာနှင့် direct BYOK အတွက် login မလိုပါ။ Cloud progress နှင့် secure code execution အတွက် account/backend ချိတ်ဆက်ထားရန် လိုပါသည်။';

  @override
  String get sync => 'တိုးတက်မှုကို ချိတ်ဆက်သိမ်းရန်';

  @override
  String get syncFailed =>
      'ဖုန်းထဲ သိမ်းပြီးပါပြီ။ Cloud sync မရသေးပါ။ ထပ်စမ်းရန် နှိပ်ပါ။';

  @override
  String get synced => 'တိုးတက်မှု ချိတ်ဆက်သိမ်းပြီးပါပြီ';

  @override
  String get syncing => 'ချိတ်ဆက်သိမ်းနေသည်…';

  @override
  String get byokSettings => 'AI provider ဆက်တင် · BYOK';

  @override
  String get provider => 'AI ဝန်ဆောင်မှုပေးသူ';

  @override
  String get model => 'Model ID';

  @override
  String get apiKey => 'သင့် API key';

  @override
  String get keySaved =>
      'Key ကို ဤဖုန်းထဲ လုံခြုံစွာ သိမ်းထားသည်။ မပြောင်းလျှင် အလွတ်ထားပါ။';

  @override
  String get byokConsent =>
      'ကျွန်ုပ်၏ key၊ မေးခွန်းနှင့် code ကို Academy backend မှတစ်ဆင့် ရွေးထားသော provider ဆီ ပို့ရန် သဘောတူသည်။ Provider အသုံးပြုခ ကုန်ကျနိုင်သည်။';

  @override
  String get byokPrivacy =>
      'Key ကို account အလိုက် ဖုန်း၏ encrypted storage တွင် သိမ်းသည်။ Backend က request တစ်ခုချင်း ပို့ပေးပြီး key ကို မသိမ်းပါ။ Chat ထဲ လျှို့ဝှက်ချက် မထည့်ပါနှင့်။';

  @override
  String get save => 'သိမ်းရန်';

  @override
  String get saved => 'သိမ်းပြီးပါပြီ';

  @override
  String get removeKey => 'သိမ်းထားသော key ဖျက်ရန်';

  @override
  String get byokInvalid =>
      'Provider ရွေးပြီး model နှင့် key ထည့်ကာ အချက်အလက်ပို့ခြင်းကို သဘောတူပါ။';

  @override
  String get storageError =>
      'လုံခြုံသောသိမ်းဆည်းစနစ် မရပါ။ ပြန်စမ်းပါ။ မည်သည့်အရာမျှ မပို့ရသေးပါ။';

  @override
  String get signInRequired =>
      'Python အမှန်တကယ် Run နှင့် server စစ်ဆေးရန် account နှင့် configured backend လိုသည်။ Guest BYOK AI အတွက် login မလိုပါ။';

  @override
  String get byokRequired =>
      'AI ဆက်တင်တွင် provider နှင့် သင့် key ကို အရင်ထည့်ပါ။';

  @override
  String get networkError =>
      'ချိတ်ဆက်မရပါ သို့မဟုတ် အချိန်ကုန်သွားပါပြီ။ ပြန်စမ်းပါ။';

  @override
  String get sessionExpired =>
      'အကောင့်ပြောင်းသွားသည် သို့မဟုတ် session သက်တမ်းကုန်ပါပြီ။ ပြန်ဝင်ပါ။';

  @override
  String get providerError =>
      'Provider က request ကို လက်မခံပါ။ Key၊ model နှင့် အသုံးပြုခွင့်ကို စစ်ပါ။';

  @override
  String get quotaError =>
      'အသုံးပြုခွင့်ကန့်သတ်ချက် သို့မဟုတ် လက်ကျန်ငွေ မလုံလောက်ပါ။ နောက်မှပြန်စမ်းပါ သို့မဟုတ် provider account ကို စစ်ပါ။';

  @override
  String get notConfigured =>
      'ဤဝန်ဆောင်မှု မချိတ်ဆက်ရသေးပါ။ Academy စီမံသူကို ဆက်သွယ်ပါ။';

  @override
  String get invalidRequest =>
      'ထည့်ထားသည်မှာ ရှည်လွန်းသည် သို့မဟုတ် မမှန်ပါ။ လျှော့ပြီး ပြန်စမ်းပါ။';

  @override
  String get ask => 'မေးရန်';

  @override
  String get explain => 'Code ရှင်းပြရန်';

  @override
  String get debug => 'Code အမှားရှာရန်';

  @override
  String get practice => 'လေ့ကျင့်ရန်';

  @override
  String get review => 'Code စစ်ဆေးရန်';

  @override
  String get mentor => 'လေ့လာမှု လမ်းညွှန်';

  @override
  String get project => 'Project အကူအညီ';

  @override
  String get question => 'Coding မေးခွန်း မေးပါ';

  @override
  String get send => 'ပို့ရန်';

  @override
  String get aiDisclaimer =>
      'AI အဖြေ မှားနိုင်သည်။ ခန့်မှန်း output သည် တကယ် run ထားသောရလဒ် မဟုတ်ပါ။';

  @override
  String get clearChat => 'Chat မှတ်တမ်း ဖျက်ရန်';

  @override
  String get copy => 'ကူးယူရန်';

  @override
  String get insertCode => 'Code Lab တွင် ဖွင့်ရန်';

  @override
  String get newChat => 'Chat အသစ်';

  @override
  String get retry => 'ပြန်စမ်းရန်';

  @override
  String get run => 'Python run ရန်';

  @override
  String get reset => 'နမူနာသို့ ပြန်ပြောင်းရန်';

  @override
  String get stdin => 'Input (တန်ဖိုးတစ်ခုကို တစ်ကြောင်းစီ)';

  @override
  String get code => 'Python code';

  @override
  String get output => 'Sandbox မှ တကယ့်ရလဒ်';

  @override
  String get errors => 'အမှား / compiler output';

  @override
  String get running => 'သီးခြား sandbox တွင် run နေသည်…';

  @override
  String get notRun => 'မ run ရသေးပါ။ တကယ့် output ကြည့်ရန် code ကို run ပါ။';

  @override
  String get fontSize => 'Code စာလုံးအရွယ်အစား';

  @override
  String get draftSaved => 'Code မူကြမ်းကို ဤဖုန်းတွင် သိမ်းပြီးပါပြီ';

  @override
  String get pythonHint =>
      'Indentation၊ စာလုံးပေါင်းနှင့် input အမျိုးအစားကို စစ်ပါ။ နောက်ဆုံး error စာကြောင်းကို အရင်ဖတ်ပါ။';

  @override
  String get outputTruncated =>
      'ပြသနိုင်သည့် ကန့်သတ်ချက်အရ output ကို ဖြတ်ထားသည်။';

  @override
  String get darkMode => 'အမှောင်အပြင်အဆင်';

  @override
  String get cancel => 'မလုပ်တော့ပါ';

  @override
  String get replaceDraft => 'လက်ရှိ code မူကြမ်းကို အစားထိုးမလား။';

  @override
  String get confirm => 'အတည်ပြုရန်';

  @override
  String get lessonContext => 'လက်ရှိသင်ခန်းစာ အချက်အလက်';

  @override
  String get aiConnection => 'AI ချိတ်ဆက်နည်း';

  @override
  String get directConnection => 'Provider သို့ တိုက်ရိုက်';

  @override
  String get backendConnection => 'Academy backend မှတစ်ဆင့်';

  @override
  String get directPrivacy =>
      'ကိုယ်ပိုင် key ကို guest နှင့် account တစ်ခုချင်းစီအတွက် သီးခြား encrypted storage တွင် သိမ်းပါမည်။ Direct mode တွင် မေးခွန်းနှင့် code ကို ရွေးထားသော provider သို့ HTTPS ဖြင့် တိုက်ရိုက်ပို့ပါမည်။ Cloud login မလိုပါ။';

  @override
  String get directConsent =>
      'ကိုယ်ပိုင် key၊ မေးခွန်းနှင့် code ကို ရွေးထားသော provider သို့ ပို့ရန် သဘောတူပါသည်။ Provider ၏ data policy နှင့် အသုံးပြုခ အကျုံးဝင်ပါသည်။';

  @override
  String get loadModels => 'သုံးနိုင်သော model များ ရယူမည်';

  @override
  String get searchModels => 'Model ID ရှာရန်';

  @override
  String get noModels =>
      'Model မရရှိပါ။ ကိုက်ညီသော model ID ကို ကိုယ်တိုင်ထည့်ပါ။';

  @override
  String get tutorWelcome =>
      '၁။ AI Provider settings ကို ဖွင့်ပါ။\n၂။ ကိုယ်ပိုင် API key ထည့်ပြီး model ရွေးပါ။ Data-sharing ကို သဘောတူ၍ Save နှိပ်ပါ။\n၃။ အောက်တွင် မေးခွန်းရေးပြီး Send နှိပ်ပါ။ Guest BYOK အတွက် Supabase setup မလိုပါ။';

  @override
  String get explainPrompt =>
      'ဒီ code ကို တစ်ကြောင်းချင်း မြန်မာလို ရှင်းပြပြီး လေ့ကျင့်ခန်းငယ်တစ်ခု ပေးပါ။';

  @override
  String get objectives => 'သင်ယူရမည့်အချက်များ';

  @override
  String get lineByLine => 'Code တစ်ကြောင်းချင်း ရှင်းလင်းချက်';

  @override
  String get commonMistakes => 'ဖြစ်တတ်သော အမှားများ';

  @override
  String get hints => 'လေ့ကျင့်ခန်းအတွက် အကြံပြုချက်';

  @override
  String get quickQuiz => 'နားလည်မှု စစ်ဆေးမည်';

  @override
  String get checkAnswer => 'အဖြေ စစ်မည်';

  @override
  String get correctAnswer => 'မှန်ပါသည်။ အောက်ပါ ရှင်းလင်းချက်ကို ဖတ်ပါ။';

  @override
  String get tryAgain => 'ထပ်စမ်းပါ။ အောက်ပါ ရှင်းလင်းချက်ကို ကြည့်ပါ။';

  @override
  String get references => 'မူရင်း documentation';

  @override
  String get startExercise => 'Code Lab တွင် လေ့ကျင့်မည်';

  @override
  String get learningHub => 'လေ့လာရေး အစီအစဉ်';

  @override
  String get learningPaths => 'လေ့လာရေး လမ်းကြောင်း';

  @override
  String get codingChallenges => 'Coding လေ့ကျင့်ခန်း';

  @override
  String get guidedProjects => 'Project လမ်းညွှန်များ';

  @override
  String get searchLearning => 'လမ်းကြောင်း၊ လေ့ကျင့်ခန်း၊ project ရှာရန်';

  @override
  String get catalogError =>
      'စက်တွင်းသင်ယူရေးအချက်အလက်ကို မဖတ်နိုင်ပါ။ ပြန်ကြိုးစားပါ။';

  @override
  String get pathNotice =>
      'ယခုပါသော သင်ခန်းစာနှင့် project guide များကို လမ်းကြောင်းအလိုက် စုထားသည်။ Project guide သည် advanced course အပြည့်ကို အစားမထိုးပါ။';

  @override
  String get choosePath => 'ဒီလမ်းကြောင်းကို ရွေးမည်';

  @override
  String get foundationLessons => 'အခြေခံ သင်ခန်းစာများ';

  @override
  String get projectLevel => 'Project အဆင့်';

  @override
  String get allLevels => 'အဆင့်အားလုံး';

  @override
  String get beginnerLevel => 'အစပြုအဆင့်';

  @override
  String get intermediateLevel => 'အလယ်အလတ်အဆင့်';

  @override
  String get advancedLevel => 'အဆင့်မြင့်';

  @override
  String get projectRequirements => 'လိုအပ်ချက်များ';

  @override
  String get projectArchitecture => 'တည်ဆောက်ပုံ';

  @override
  String get projectWorkflow => 'အဆင့်လိုက် လုပ်ဆောင်ရန်';

  @override
  String get projectTests => 'စမ်းသပ်ရမည့်အချက်များ';

  @override
  String get projectTroubleshooting => 'အမှားရှာဖွေခြင်း';

  @override
  String get projectCompletion => 'ပြီးဆုံးရန် သတ်မှတ်ချက်များ';

  @override
  String get projectNotes => 'ကိုယ်ပိုင် project မှတ်စု';

  @override
  String get projectProgressNotice =>
      'လုပ်ပြီးသောအဆင့်ကို ကိုယ်တိုင် မှတ်သားပါ။ စက်တွင် account/guest သီးခြား သိမ်းသည်။ Certification သို့ server အတည်ပြုချက် မဟုတ်ပါ။';

  @override
  String get starterCode => 'စတင်လေ့ကျင့်ရန် နမူနာ';

  @override
  String get starterNotice =>
      'ဒီနမူနာသည် စတင်ရန် အပိုင်းတစ်ခုဖြစ်သည်။ Guide ၏ လိုအပ်ချက်၊ tests နှင့် completion များကို ကိုယ်တိုင် ဆက်တည်ဆောက်ပါ။';

  @override
  String get publicExamples => 'လေ့လာရန် နမူနာ input/output';

  @override
  String get expectedOutput => 'မျှော်မှန်း output';

  @override
  String get selectExample => 'နမူနာရွေးရန်';

  @override
  String get runExample => 'နမူနာကို အမှန်တကယ် run မည်';

  @override
  String get assessmentNotice =>
      'Code ရေး၊ hint နှင့် နမူနာများကို offline ဖတ်နိုင်သည်။ အမှန်တကယ် Run နှင့် server စစ်ဆေးရန် account၊ HTTPS backend၊ verified sandbox နှင့် assessment database configuration လိုသည်။';

  @override
  String get submitAssessment => 'Server ဖြင့် စစ်ဆေးမည်';

  @override
  String get checkResult => 'အရင်ဖြေဆိုမှု ရလဒ် စစ်မည်';

  @override
  String get newAttempt => 'ဖြေဆိုမှုအသစ် စမည်';

  @override
  String get newAttemptWarning =>
      'အရင် execution သည် အလုပ်လုပ်နေဆဲ ဖြစ်နိုင်သည်။ အသစ်စလျှင် သီးခြား execution နှင့် quota အသုံးပြုမှု ဖြစ်မည်။ အရင်ရလဒ်ကို အလိုအလျောက် ပြန် run မလုပ်ပါ။';

  @override
  String get pendingAttempt =>
      'အရင်ဖြေဆိုမှု မပြီးသေးပါ။ ရလဒ်စစ်ပါ၊ သို့မဟုတ် ဖြေဆိုမှုအသစ်ကို ရည်ရွယ်ချက်ရှိရှိ စပါ။';

  @override
  String get gradePassed =>
      'Server စမ်းသပ်ချက်များ အောင်မြင်သည်။ ပို့ထားသော code ၏ ရလဒ်ဖြစ်သည်။';

  @override
  String get gradeWrong =>
      'ရလဒ် မကိုက်ပါ။ Input ပြောင်းလဲမှု၊ boundary နှင့် အပို print များကို စစ်ပါ။';

  @override
  String get gradeRuntime =>
      'Runtime/compile အမှား ရှိသည်။ Public example ကို run၍ error ကို ဖတ်ပါ။';

  @override
  String get gradeTimeout =>
      'အချိန်ကန့်သတ်ချက် ပြည့်သွားသည်။ Loop ရပ်နိုင်မှုကို စစ်ပါ။';

  @override
  String get gradeOutput =>
      'Output ကန့်သတ်ချက် ကျော်သည်။ မလိုအပ်သော print နှင့် loop ကို စစ်ပါ။';

  @override
  String get gradeService =>
      'Server/sandbox စစ်ဆေးမှု မပြီးပါ။ Quota၊ service configuration နှင့် connection ကို စစ်ပါ။ အဖြေမှန်ဟု မသတ်မှတ်ပါ။';

  @override
  String get sampleSolution => 'နမူနာ အဖြေကြည့်ရန်';

  @override
  String get attemptNotFound =>
      'ဖြေဆိုမှုမှတ်တမ်း မတွေ့ပါ။ Request သည် server သို့ မရောက်ခဲ့ခြင်း ဖြစ်နိုင်သည်။ အဆင်သင့်ဖြစ်မှ ဖြေဆိုမှုအသစ်ကို ရည်ရွယ်ချက်ရှိရှိ စပါ။';

  @override
  String get assessmentHistory => 'Server ဖြေဆိုမှုမှတ်တမ်း';

  @override
  String get historyNotice =>
      'သင်ပို့ထားသော code ၏ server မှတ်တမ်း နောက်ဆုံး ၃၀ ခု ဖြစ်သည်။ နမူနာ solution ကြည့်ခြင်းသည် အလိုအလျောက် passing grade မရစေပါ။';

  @override
  String get noAttempts => 'Server ဖြေဆိုမှုမှတ်တမ်း မရှိသေးပါ။';

  @override
  String get gradeNotPassed =>
      'စစ်ဆေးမှု မအောင်မြင်သေးပါ။ လေ့ကျင့်ခန်းကို ပြန်လေ့လာပြီး ဖြေဆိုမှုအသစ်ကို စမ်းပါ။';
}
