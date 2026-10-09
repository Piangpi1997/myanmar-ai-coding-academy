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
      'Cloud အသုံးပြုရန် အကောင့်နှင့် HTTPS backend ချိတ်ဆက်ထားရန် လိုသည်။ ဧည့်သည်သင်ခန်းစာများကို offline ဖတ်နိုင်သည်။';

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
      'Cloud AI နှင့် code run အသုံးပြုရန် အကောင့်ဝင်ပါ။';

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
}
