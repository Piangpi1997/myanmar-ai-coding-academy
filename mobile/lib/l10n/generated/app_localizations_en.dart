// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get home => 'Home';

  @override
  String get learn => 'Learn';

  @override
  String get profile => 'Profile';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Create account';

  @override
  String get signOut => 'Sign out';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get wait => 'Please wait…';

  @override
  String get authInvalid =>
      'Enter a valid email and at least 8 password characters.';

  @override
  String get authFailed =>
      'Could not sign in. Check your details, email verification and connection.';

  @override
  String get checkEmail =>
      'Check your email for a verification or recovery link.';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get updatePassword => 'Set new password';

  @override
  String get passwordUpdated => 'Password updated.';

  @override
  String get switchAuth => 'Switch sign in / registration';

  @override
  String get guest => 'Learning as a guest';

  @override
  String get cloudNotice =>
      'Cloud features need a configured account and HTTPS backend. Guest lessons work offline.';

  @override
  String get sync => 'Sync progress';

  @override
  String get syncFailed =>
      'Saved locally. Cloud sync unavailable; tap to retry.';

  @override
  String get synced => 'Progress synchronized';

  @override
  String get syncing => 'Synchronizing…';

  @override
  String get byokSettings => 'AI provider settings · BYOK';

  @override
  String get provider => 'AI provider';

  @override
  String get model => 'Model ID';

  @override
  String get apiKey => 'Your API key';

  @override
  String get keySaved =>
      'Key saved securely on this device. Leave blank to keep it.';

  @override
  String get byokConsent =>
      'I agree to send my key, prompts and code through this academy backend to the selected provider. Provider usage may cost money.';

  @override
  String get byokPrivacy =>
      'Keys stay in encrypted device storage per account. The backend forwards the key for each request without storing it. Do not paste secrets into chat.';

  @override
  String get save => 'Save';

  @override
  String get saved => 'Saved';

  @override
  String get removeKey => 'Remove saved key';

  @override
  String get byokInvalid =>
      'Choose a provider, enter a model and key, and accept the data-sharing notice.';

  @override
  String get storageError =>
      'Secure storage unavailable. Please retry; nothing was sent.';

  @override
  String get signInRequired => 'Sign in to use cloud AI and code execution.';

  @override
  String get byokRequired => 'Add your provider and key in AI settings first.';

  @override
  String get networkError => 'Connection failed or timed out. Try again.';

  @override
  String get sessionExpired =>
      'Your session changed or expired. Sign in again.';

  @override
  String get providerError =>
      'Provider rejected the request. Check key, model and provider access.';

  @override
  String get quotaError =>
      'Usage limit or provider balance reached. Try later or check your provider account.';

  @override
  String get notConfigured =>
      'This service is not configured. Contact the academy administrator.';

  @override
  String get invalidRequest =>
      'Input is too long or invalid. Shorten it and try again.';

  @override
  String get ask => 'Ask';

  @override
  String get explain => 'Explain code';

  @override
  String get debug => 'Debug code';

  @override
  String get practice => 'Practice';

  @override
  String get review => 'Review code';

  @override
  String get mentor => 'Learning mentor';

  @override
  String get project => 'Project assistant';

  @override
  String get question => 'Ask a coding question';

  @override
  String get send => 'Send';

  @override
  String get aiDisclaimer =>
      'AI may be wrong. Predicted output is not an executed result.';

  @override
  String get clearChat => 'Clear chat history';

  @override
  String get copy => 'Copy';

  @override
  String get insertCode => 'Open code in Code Lab';

  @override
  String get newChat => 'New chat';

  @override
  String get retry => 'Retry';

  @override
  String get run => 'Run Python';

  @override
  String get reset => 'Reset example';

  @override
  String get stdin => 'Standard input (one value per line)';

  @override
  String get code => 'Python code';

  @override
  String get output => 'Actual sandbox output';

  @override
  String get errors => 'Errors / compiler output';

  @override
  String get running => 'Running in remote sandbox…';

  @override
  String get notRun => 'No execution yet. Run your code to see actual output.';

  @override
  String get fontSize => 'Editor font size';

  @override
  String get draftSaved => 'Draft saved on this device';

  @override
  String get pythonHint =>
      'Check indentation, spelling and input types. Read the last error line first.';

  @override
  String get outputTruncated =>
      'Output was shortened to fit the display limit.';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get cancel => 'Cancel';

  @override
  String get replaceDraft => 'Replace the current code draft?';

  @override
  String get confirm => 'Confirm';

  @override
  String get lessonContext => 'Current lesson context';
}
