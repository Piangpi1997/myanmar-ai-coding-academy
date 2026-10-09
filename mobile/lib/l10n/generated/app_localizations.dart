import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_my.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('my'),
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @learn.
  ///
  /// In en, this message translates to:
  /// **'Learn'**
  String get learn;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @wait.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get wait;

  /// No description provided for @authInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email and at least 8 password characters.'**
  String get authInvalid;

  /// No description provided for @authFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not sign in. Check your details, email verification and connection.'**
  String get authFailed;

  /// No description provided for @checkEmail.
  ///
  /// In en, this message translates to:
  /// **'Check your email for a verification or recovery link.'**
  String get checkEmail;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Set new password'**
  String get updatePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated.'**
  String get passwordUpdated;

  /// No description provided for @switchAuth.
  ///
  /// In en, this message translates to:
  /// **'Switch sign in / registration'**
  String get switchAuth;

  /// No description provided for @guest.
  ///
  /// In en, this message translates to:
  /// **'Learning as a guest'**
  String get guest;

  /// No description provided for @cloudNotice.
  ///
  /// In en, this message translates to:
  /// **'Cloud features need a configured account and HTTPS backend. Guest lessons work offline.'**
  String get cloudNotice;

  /// No description provided for @sync.
  ///
  /// In en, this message translates to:
  /// **'Sync progress'**
  String get sync;

  /// No description provided for @syncFailed.
  ///
  /// In en, this message translates to:
  /// **'Saved locally. Cloud sync unavailable; tap to retry.'**
  String get syncFailed;

  /// No description provided for @synced.
  ///
  /// In en, this message translates to:
  /// **'Progress synchronized'**
  String get synced;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Synchronizing…'**
  String get syncing;

  /// No description provided for @byokSettings.
  ///
  /// In en, this message translates to:
  /// **'AI provider settings · BYOK'**
  String get byokSettings;

  /// No description provided for @provider.
  ///
  /// In en, this message translates to:
  /// **'AI provider'**
  String get provider;

  /// No description provided for @model.
  ///
  /// In en, this message translates to:
  /// **'Model ID'**
  String get model;

  /// No description provided for @apiKey.
  ///
  /// In en, this message translates to:
  /// **'Your API key'**
  String get apiKey;

  /// No description provided for @keySaved.
  ///
  /// In en, this message translates to:
  /// **'Key saved securely on this device. Leave blank to keep it.'**
  String get keySaved;

  /// No description provided for @byokConsent.
  ///
  /// In en, this message translates to:
  /// **'I agree to send my key, prompts and code through this academy backend to the selected provider. Provider usage may cost money.'**
  String get byokConsent;

  /// No description provided for @byokPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Keys stay in encrypted device storage per account. The backend forwards the key for each request without storing it. Do not paste secrets into chat.'**
  String get byokPrivacy;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saved;

  /// No description provided for @removeKey.
  ///
  /// In en, this message translates to:
  /// **'Remove saved key'**
  String get removeKey;

  /// No description provided for @byokInvalid.
  ///
  /// In en, this message translates to:
  /// **'Choose a provider, enter a model and key, and accept the data-sharing notice.'**
  String get byokInvalid;

  /// No description provided for @storageError.
  ///
  /// In en, this message translates to:
  /// **'Secure storage unavailable. Please retry; nothing was sent.'**
  String get storageError;

  /// No description provided for @signInRequired.
  ///
  /// In en, this message translates to:
  /// **'Sign in to use cloud AI and code execution.'**
  String get signInRequired;

  /// No description provided for @byokRequired.
  ///
  /// In en, this message translates to:
  /// **'Add your provider and key in AI settings first.'**
  String get byokRequired;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Connection failed or timed out. Try again.'**
  String get networkError;

  /// No description provided for @sessionExpired.
  ///
  /// In en, this message translates to:
  /// **'Your session changed or expired. Sign in again.'**
  String get sessionExpired;

  /// No description provided for @providerError.
  ///
  /// In en, this message translates to:
  /// **'Provider rejected the request. Check key, model and provider access.'**
  String get providerError;

  /// No description provided for @quotaError.
  ///
  /// In en, this message translates to:
  /// **'Usage limit or provider balance reached. Try later or check your provider account.'**
  String get quotaError;

  /// No description provided for @notConfigured.
  ///
  /// In en, this message translates to:
  /// **'This service is not configured. Contact the academy administrator.'**
  String get notConfigured;

  /// No description provided for @invalidRequest.
  ///
  /// In en, this message translates to:
  /// **'Input is too long or invalid. Shorten it and try again.'**
  String get invalidRequest;

  /// No description provided for @ask.
  ///
  /// In en, this message translates to:
  /// **'Ask'**
  String get ask;

  /// No description provided for @explain.
  ///
  /// In en, this message translates to:
  /// **'Explain code'**
  String get explain;

  /// No description provided for @debug.
  ///
  /// In en, this message translates to:
  /// **'Debug code'**
  String get debug;

  /// No description provided for @practice.
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;

  /// No description provided for @review.
  ///
  /// In en, this message translates to:
  /// **'Review code'**
  String get review;

  /// No description provided for @mentor.
  ///
  /// In en, this message translates to:
  /// **'Learning mentor'**
  String get mentor;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project assistant'**
  String get project;

  /// No description provided for @question.
  ///
  /// In en, this message translates to:
  /// **'Ask a coding question'**
  String get question;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @aiDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'AI may be wrong. Predicted output is not an executed result.'**
  String get aiDisclaimer;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat history'**
  String get clearChat;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @insertCode.
  ///
  /// In en, this message translates to:
  /// **'Open code in Code Lab'**
  String get insertCode;

  /// No description provided for @newChat.
  ///
  /// In en, this message translates to:
  /// **'New chat'**
  String get newChat;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @run.
  ///
  /// In en, this message translates to:
  /// **'Run Python'**
  String get run;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset example'**
  String get reset;

  /// No description provided for @stdin.
  ///
  /// In en, this message translates to:
  /// **'Standard input (one value per line)'**
  String get stdin;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Python code'**
  String get code;

  /// No description provided for @output.
  ///
  /// In en, this message translates to:
  /// **'Actual sandbox output'**
  String get output;

  /// No description provided for @errors.
  ///
  /// In en, this message translates to:
  /// **'Errors / compiler output'**
  String get errors;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running in remote sandbox…'**
  String get running;

  /// No description provided for @notRun.
  ///
  /// In en, this message translates to:
  /// **'No execution yet. Run your code to see actual output.'**
  String get notRun;

  /// No description provided for @fontSize.
  ///
  /// In en, this message translates to:
  /// **'Editor font size'**
  String get fontSize;

  /// No description provided for @draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft saved on this device'**
  String get draftSaved;

  /// No description provided for @pythonHint.
  ///
  /// In en, this message translates to:
  /// **'Check indentation, spelling and input types. Read the last error line first.'**
  String get pythonHint;

  /// No description provided for @outputTruncated.
  ///
  /// In en, this message translates to:
  /// **'Output was shortened to fit the display limit.'**
  String get outputTruncated;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @replaceDraft.
  ///
  /// In en, this message translates to:
  /// **'Replace the current code draft?'**
  String get replaceDraft;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @lessonContext.
  ///
  /// In en, this message translates to:
  /// **'Current lesson context'**
  String get lessonContext;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'my'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'my':
      return AppLocalizationsMy();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
