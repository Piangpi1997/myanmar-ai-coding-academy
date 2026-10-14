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
      'Guest lessons and direct BYOK work without login. Cloud progress and secure code execution need a configured account/backend.';

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
  String get signInRequired =>
      'Sign in with a configured backend to execute Python and submit assessments. Guest BYOK AI works without login.';

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

  @override
  String get aiConnection => 'AI connection';

  @override
  String get directConnection => 'Direct to provider';

  @override
  String get backendConnection => 'Academy backend';

  @override
  String get directPrivacy =>
      'Your key stays in encrypted storage, separately for guests and each account. Direct mode sends your prompts and code straight to the selected provider over HTTPS. Cloud login is optional.';

  @override
  String get directConsent =>
      'I agree to share my key, prompts and code with the selected provider. Its data policies and usage charges apply.';

  @override
  String get loadModels => 'Load available models';

  @override
  String get searchModels => 'Search model IDs';

  @override
  String get noModels =>
      'No models returned. Enter a compatible model ID manually.';

  @override
  String get tutorWelcome =>
      '1. Open AI provider settings.\n2. Enter your own API key and select a model; accept the sharing notice and save.\n3. Type a question below and tap Send. Guest BYOK works without Supabase setup.';

  @override
  String get explainPrompt =>
      'Explain this code line by line and suggest a small practice exercise.';

  @override
  String get objectives => 'Learning objectives';

  @override
  String get lineByLine => 'Line-by-line explanation';

  @override
  String get commonMistakes => 'Common mistakes';

  @override
  String get hints => 'Practice hint';

  @override
  String get quickQuiz => 'Quick check';

  @override
  String get checkAnswer => 'Check answer';

  @override
  String get correctAnswer => 'Correct — read the explanation below.';

  @override
  String get tryAgain => 'Try again — use the explanation below.';

  @override
  String get references => 'Official references';

  @override
  String get startExercise => 'Practice in Code Lab';

  @override
  String get learningHub => 'Learning workspace';

  @override
  String get learningPaths => 'Learning paths';

  @override
  String get codingChallenges => 'Coding challenges';

  @override
  String get guidedProjects => 'Guided projects';

  @override
  String get searchLearning => 'Search paths, challenges and projects';

  @override
  String get catalogError =>
      'Local learning material could not be read. Try again.';

  @override
  String get pathNotice =>
      'Paths organize the currently shipped lessons and project guides. A guide is not a complete advanced course.';

  @override
  String get choosePath => 'Choose this path';

  @override
  String get foundationLessons => 'Foundation lessons';

  @override
  String get projectLevel => 'Project level';

  @override
  String get allLevels => 'All levels';

  @override
  String get beginnerLevel => 'Beginner';

  @override
  String get intermediateLevel => 'Intermediate';

  @override
  String get advancedLevel => 'Advanced';

  @override
  String get projectRequirements => 'Requirements';

  @override
  String get projectArchitecture => 'Architecture';

  @override
  String get projectWorkflow => 'Step-by-step workflow';

  @override
  String get projectTests => 'Tests to perform';

  @override
  String get projectTroubleshooting => 'Troubleshooting';

  @override
  String get projectCompletion => 'Completion requirements';

  @override
  String get projectNotes => 'Your project notes';

  @override
  String get projectProgressNotice =>
      'Mark steps you have completed. Progress is local and separated by account/guest. It is not certification or server verification.';

  @override
  String get starterCode => 'Starter snippet';

  @override
  String get starterNotice =>
      'This snippet is a starting component. Build the guide’s requirements and complete its tests before marking the project finished.';

  @override
  String get publicExamples => 'Public worked examples';

  @override
  String get expectedOutput => 'Expected output';

  @override
  String get selectExample => 'Select example';

  @override
  String get runExample => 'Run example';

  @override
  String get assessmentNotice =>
      'Edit code and read hints/examples offline. Actual execution and server grading require an account, HTTPS backend, verified sandbox and configured assessment storage.';

  @override
  String get submitAssessment => 'Submit for server grading';

  @override
  String get checkResult => 'Check existing result';

  @override
  String get newAttempt => 'Start a new attempt';

  @override
  String get newAttemptWarning =>
      'The earlier execution may still finish. A new attempt starts separate execution and uses quota. The previous request is never automatically run again.';

  @override
  String get pendingAttempt =>
      'An earlier attempt is unresolved. Check its result or explicitly start a new attempt.';

  @override
  String get gradePassed => 'All server checks passed for the submitted code.';

  @override
  String get gradeWrong =>
      'Output does not match. Check varied inputs, boundaries and extra prints.';

  @override
  String get gradeRuntime =>
      'Execution/compilation failed. Run a public example to inspect the error.';

  @override
  String get gradeTimeout =>
      'The time limit was reached. Check loop termination.';

  @override
  String get gradeOutput =>
      'Output exceeded the limit. Check unnecessary prints and loops.';

  @override
  String get gradeService =>
      'Server/sandbox grading did not complete. Check quotas, configuration and connectivity; this is not a passing result.';

  @override
  String get sampleSolution => 'View a sample solution';

  @override
  String get attemptNotFound =>
      'The attempt was not found. It may never have reached the server; explicitly start a new attempt only when ready.';

  @override
  String get assessmentHistory => 'Server assessment history';

  @override
  String get historyNotice =>
      'These are your latest 30 server-recorded code attempts. Viewing a sample solution does not automatically award a passing grade.';

  @override
  String get noAttempts => 'No server attempts yet.';

  @override
  String get gradeNotPassed =>
      'The assessment has not passed. Review the challenge before starting a new attempt.';
}
