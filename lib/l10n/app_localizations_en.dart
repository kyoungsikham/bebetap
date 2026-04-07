// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'BebeTap';

  @override
  String get tabHome => 'Home';

  @override
  String get tabStatistics => 'Stats';

  @override
  String get tabLog => 'Log';

  @override
  String get tabFamily => 'Family';

  @override
  String get menuBabyManage => 'Baby Management';

  @override
  String get menuWidgetAdd => 'Add Widget';

  @override
  String get menuIconSettings => 'Icon Settings';

  @override
  String get menuLanguage => 'Language';

  @override
  String get menuLogout => 'Logout';

  @override
  String get logoutConfirmTitle => 'Logout';

  @override
  String get logoutConfirmMessage => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name!';
  }

  @override
  String get homeEncouragement =>
      'Parenting is hard, but you\'re doing amazing! 💛';

  @override
  String get sectionRecord => 'Record';

  @override
  String get formula => 'Formula';

  @override
  String get breast => 'Breastfeed';

  @override
  String get pumped => 'Pumped';

  @override
  String get babyFood => 'Baby Food';

  @override
  String get diaper => 'Diaper';

  @override
  String get sleep => 'Sleep';

  @override
  String get temperature => 'Temperature';

  @override
  String get growth => 'Growth';

  @override
  String get diary => 'Diary';

  @override
  String get statsFormulaLabel => 'Formula';

  @override
  String get statsSleepLabel => 'Sleep';

  @override
  String get statsDiaperLabel => 'Diaper';

  @override
  String get tapToRecord => 'Tap to record';

  @override
  String get formulaBottomSheetTitle => 'Formula Feeding';

  @override
  String get breastBottomSheetTitle => 'Breastfeeding';

  @override
  String get pumpedBottomSheetTitle => 'Pumped Feeding';

  @override
  String get babyFoodBottomSheetTitle => 'Baby Food Record';

  @override
  String get temperatureRecordTitle => 'Temperature Record';

  @override
  String get diaryWriteTitle => 'Write Diary';

  @override
  String get diaryEditTitle => 'Edit Diary';

  @override
  String get diaryDoneToday => 'Written today';

  @override
  String get sleepActive => 'Sleeping';

  @override
  String get lastFeeding => 'Last feeding';

  @override
  String get formulaTotal => 'Formula total';

  @override
  String get noRecord => 'No records yet';

  @override
  String get startRecordingHint => 'Tap the feeding tile to start';

  @override
  String get typeBreastFeeding => 'Breastfeeding';

  @override
  String get typePumpedFeeding => 'Pumped';

  @override
  String get typeBabyFood => 'Baby Food';

  @override
  String get typeFormulaFeeding => 'Formula';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get weekdayMon => 'Mon';

  @override
  String get weekdayTue => 'Tue';

  @override
  String get weekdayWed => 'Wed';

  @override
  String get weekdayThu => 'Thu';

  @override
  String get weekdayFri => 'Fri';

  @override
  String get weekdaySat => 'Sat';

  @override
  String get weekdaySun => 'Sun';

  @override
  String dateFormatMonthDay(int month, int day) {
    return '$month/$day';
  }

  @override
  String dateFormatFull(int month, int day, String weekday) {
    return '$month/$day ($weekday)';
  }

  @override
  String dateFormatTodayNav(int month, int day, String weekday) {
    return '$month/$day ($weekday)  Today';
  }

  @override
  String get save => 'Save';

  @override
  String get edit => 'Edit';

  @override
  String get confirm => 'Confirm';

  @override
  String saveAmountMl(int amount) {
    return 'Save ${amount}ml';
  }

  @override
  String editAmountMl(int amount) {
    return 'Edit ${amount}ml';
  }

  @override
  String formulaRecommendation(String weight, int ml) {
    return '${weight}kg → recommended ${ml}ml/day';
  }

  @override
  String get formulaWeightHint => 'Enter baby weight to see recommendation';

  @override
  String todayAmount(int amount) {
    return 'Today ${amount}ml';
  }

  @override
  String todayCount(int count) {
    return 'Today $count times';
  }

  @override
  String todayDuration(String duration) {
    return 'Today $duration';
  }

  @override
  String get left => 'Left';

  @override
  String get right => 'Right';

  @override
  String minuteUnit(int min) {
    return '${min}min';
  }

  @override
  String get diaperSelectType => 'Select diaper type';

  @override
  String get diaperWet => 'Wet';

  @override
  String get diaperSoiled => 'Soiled';

  @override
  String get diaperBoth => 'Wet+Soiled';

  @override
  String get diaperChange => 'Change';

  @override
  String get sleepEdit => 'Edit Sleep';

  @override
  String get sleepRecord => 'Record Sleep';

  @override
  String get sleepStart => 'Start Sleep';

  @override
  String get sleepEnd => 'End Sleep';

  @override
  String get sleepHint =>
      'Timer starts when sleep begins.\nRecords are kept even when app is closed.';

  @override
  String get sleepEndTimeError => 'End time cannot be before start time';

  @override
  String get startTime => 'Start';

  @override
  String get endTime => 'End';

  @override
  String startHourMinute(int hour, String minute) {
    return '$hour:$minute';
  }

  @override
  String get measureMethod => 'Measurement method';

  @override
  String get methodAxillary => 'Axillary';

  @override
  String get methodEar => 'Ear';

  @override
  String get methodForehead => 'Forehead';

  @override
  String get methodRectal => 'Rectal';

  @override
  String get highFeverWarning => 'High fever. Consult a doctor immediately.';

  @override
  String get lowFeverWarning => 'Low fever. Monitor closely.';

  @override
  String get diaryTitleHint => 'Enter title';

  @override
  String get diaryContentHint => 'Write about your day with baby...';

  @override
  String get diaryAuthorLabel => 'Author';

  @override
  String get diaryReadOnly =>
      'This diary belongs to another author and cannot be edited.';

  @override
  String get loginSubtitle => 'Parenting record app for new parents';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get signupWithEmail => 'Sign up with email';

  @override
  String get login => 'Login';

  @override
  String get orSocialLogin => 'Or social login';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithKakao => 'Continue with Kakao';

  @override
  String get continueWithFacebook => 'Continue with Facebook';

  @override
  String get continueWithLine => 'Continue with Line';

  @override
  String get invalidEmailPassword => 'Incorrect email or password';

  @override
  String get networkError => 'Network error. Please try again.';

  @override
  String loginFailed(String error) {
    return 'Login failed: $error';
  }

  @override
  String get passwordReset => 'Password Reset';

  @override
  String get emailAddressLabel => 'Email address';

  @override
  String get send => 'Send';

  @override
  String get resetEmailSent => 'Password reset email has been sent.';

  @override
  String sendFailed(String error) {
    return 'Send failed: $error';
  }

  @override
  String get emailSignupTitle => 'Email Sign Up';

  @override
  String get enterEmailPrompt => 'Enter your email address to sign up';

  @override
  String get sendVerification => 'Send Verification Email';

  @override
  String get alreadyHaveAccount => 'Already have an account? Login';

  @override
  String get setPasswordTitle => 'Set Password';

  @override
  String get setPasswordHint =>
      'You will use this email and password for future logins';

  @override
  String get passwordInput => 'Password (6+ characters)';

  @override
  String get passwordConfirm => 'Confirm Password';

  @override
  String get enterOtpTitle => 'Enter Verification Code';

  @override
  String get enterOtpHint => 'Enter the 6-digit code sent to your email';

  @override
  String get completeSignup => 'Complete Sign Up';

  @override
  String get resendEmail => 'Resend Email';

  @override
  String get invalidEmail => 'Please enter a valid email address';

  @override
  String get emailAlreadyExists =>
      'Email already registered. Redirecting to login.';

  @override
  String sendOtpFailed(String error) {
    return 'Send failed: $error';
  }

  @override
  String get passwordTooShort => 'Password must be at least 6 characters';

  @override
  String get passwordMismatch => 'Passwords do not match';

  @override
  String get enterSixDigitCode => 'Please enter the 6-digit code';

  @override
  String signupFailed(String error) {
    return 'Sign up failed: $error';
  }

  @override
  String get resendSuccess => 'Verification code resent.';

  @override
  String resendFailed(String error) {
    return 'Resend failed: $error';
  }

  @override
  String get next => 'Next';

  @override
  String get babyManageTitle => 'Baby Management';

  @override
  String get registeredBabies => 'Registered babies';

  @override
  String get addNewBaby => 'Add new baby';

  @override
  String get babyName => 'Baby Name *';

  @override
  String get birthDate => 'Birth Date *';

  @override
  String get genderOptional => 'Gender (optional)';

  @override
  String get boy => 'Boy';

  @override
  String get girl => 'Girl';

  @override
  String get currentWeight => 'Current Weight kg (optional)';

  @override
  String get photoSelect => 'Select photo (optional)';

  @override
  String get selectBirthDate => 'Select a date';

  @override
  String get birthDatePrompt => 'Please select a birth date';

  @override
  String get babyNameHint => 'e.g. John';

  @override
  String get babyNameRequired => 'Please enter a name';

  @override
  String get invalidWeight => 'Please enter a valid weight (0~30 kg)';

  @override
  String get weightHint => 'e.g. 4.5';

  @override
  String get weightFormulaHint =>
      'Entering weight calculates daily formula recommendation';

  @override
  String get babyRelationship => 'Relationship with baby *';

  @override
  String get or => 'Or';

  @override
  String get joinWithInviteCode => 'Join with invite code';

  @override
  String get selectBaby => 'Select Baby';

  @override
  String get babySetupTitle => 'Baby Information';

  @override
  String get babyEditTitle => 'Edit Baby';

  @override
  String get babyAddTitle => 'Add Baby';

  @override
  String get addButton => 'Add';

  @override
  String get editButton => 'Edit';

  @override
  String get noFamilyFound => 'Family information not found';

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String loadFailed(String error) {
    return 'Load failed: $error';
  }

  @override
  String get babyRelationshipPrompt =>
      'Please select your relationship with baby';

  @override
  String get startButton => 'Start';

  @override
  String get dateFormat => 'yyyy/MM/dd';

  @override
  String get relationMom => 'Mom';

  @override
  String get relationDad => 'Dad';

  @override
  String get relationGrandma => 'Grandma';

  @override
  String get relationGrandpa => 'Grandpa';

  @override
  String get relationAunt => 'Aunt';

  @override
  String get relationUncle => 'Uncle';

  @override
  String get relationPaternalAunt => 'Paternal Aunt';

  @override
  String get relationMaternalUncle => 'Maternal Uncle';

  @override
  String get relationCustom => 'Custom';

  @override
  String get relationCustomHint => 'e.g. Stepmother, Nanny';

  @override
  String get familyTitle => 'Family Sharing';

  @override
  String get familyGroupName => 'Family name';

  @override
  String get familyNameHint => 'e.g. Smith family';

  @override
  String get createFamilyDialog => 'Create Family Group';

  @override
  String get makeFamily => 'Create';

  @override
  String get createFamily => 'Create new family group';

  @override
  String get noFamily => 'No family group';

  @override
  String get noFamilyHint => 'Create a family or join with invite code';

  @override
  String get inviteCode => 'Invite code';

  @override
  String get inviteCodeCopied => 'Invite code copied';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get inviteCodeShareHint =>
      'Share this code with family to record together';

  @override
  String get familyMembers => 'Family members';

  @override
  String get familyError => 'An error occurred';

  @override
  String get joinFamily => 'Join with invite code';

  @override
  String get enterInviteCode => 'Enter invite code';

  @override
  String get relationshipLabel => 'Relationship with baby';

  @override
  String get joinButton => 'Join Family';

  @override
  String get enterInviteCodeError => 'Please enter an invite code';

  @override
  String get selectRelationshipError =>
      'Please select your relationship with baby';

  @override
  String get me => 'Me';

  @override
  String get userLabel => 'User';

  @override
  String get caregiverRole => 'Caregiver';

  @override
  String get familyRole => 'Family';

  @override
  String get familyLoadFailed => 'Load failed';

  @override
  String familyShareMessage(String familyName, String code) {
    return 'Join $familyName on BebeTap!\nInvite code: $code';
  }

  @override
  String get familyShareSubject => 'BebeTap Family Invite';

  @override
  String get statistics => 'Statistics';

  @override
  String get sleepSection => 'Sleep';

  @override
  String get totalSleep => 'Total sleep';

  @override
  String get feedingSection => 'Feeding';

  @override
  String get noFeedingRecord => 'No records';

  @override
  String get diaperSection => 'Diaper';

  @override
  String get diaperChangeLabel => 'Diaper change';

  @override
  String timesCount(int count) {
    return '$count times';
  }

  @override
  String diaryCountUnit(int count) {
    return '$count entries';
  }

  @override
  String get dataLoadFailed => 'Cannot load data';

  @override
  String get periodDay => 'Today';

  @override
  String get periodWeek => 'Week';

  @override
  String get periodMonth => 'Month';

  @override
  String get logTitle => 'Parenting Log';

  @override
  String get logLoadFailed => 'Could not load records';

  @override
  String get noLogForDay => 'No records for this day';

  @override
  String get addLogHint => 'Tap + to add a record';

  @override
  String get editFormula => 'Edit Formula';

  @override
  String get editPumped => 'Edit Pumped';

  @override
  String get editBabyFood => 'Edit Baby Food';

  @override
  String get editBreast => 'Edit Breastfeeding';

  @override
  String get editDiaper => 'Edit Diaper';

  @override
  String get editSleep => 'Edit Sleep';

  @override
  String get editTemperature => 'Edit Temperature';

  @override
  String get diaryLog => 'Diary';

  @override
  String get addFormula => 'Formula Feeding';

  @override
  String get addPumped => 'Pumped Feeding';

  @override
  String get addBabyFood => 'Baby Food';

  @override
  String get addBreast => 'Breastfeeding';

  @override
  String get addDiaper => 'Diaper';

  @override
  String get addSleep => 'Sleep';

  @override
  String get addTemperature => 'Temperature';

  @override
  String get editDiary => 'Edit Diary';

  @override
  String get writeDiary => 'Write Diary';

  @override
  String get entryFormula => 'Formula';

  @override
  String get entryBreast => 'Breastfeed';

  @override
  String get entryPumped => 'Pumped';

  @override
  String get entryBabyFood => 'Baby Food';

  @override
  String get entrySleep => 'Sleep';

  @override
  String get entrySleeping => 'Sleeping';

  @override
  String get entryDiaper => 'Diaper';

  @override
  String get entryTemperature => 'Temperature';

  @override
  String durationSeconds(int s) {
    return '${s}s';
  }

  @override
  String durationMinutesOnly(int m) {
    return '${m}m';
  }

  @override
  String durationHoursOnly(int h) {
    return '${h}h';
  }

  @override
  String durationHoursMinutes(int h, int m) {
    return '${h}h ${m}m';
  }

  @override
  String get elapsedJustNow => 'Just now';

  @override
  String elapsedMinutes(int m) {
    return '${m}min ago';
  }

  @override
  String elapsedHoursOnly(int h) {
    return '${h}h ago';
  }

  @override
  String elapsedHoursMinutes(int h, int m) {
    return '${h}h ${m}m ago';
  }

  @override
  String get settings => 'Settings';

  @override
  String get iconSettingsTitle => 'Icon Settings';

  @override
  String get iconSettingsHint => 'Drag to reorder, toggle to show/hide.';

  @override
  String get logout => 'Logout';

  @override
  String get pickerToday => 'Today';

  @override
  String get pickerHour => 'h';

  @override
  String get pickerMinute => 'm';

  @override
  String get pickerConfirm => 'Confirm';

  @override
  String displayTime(int h, String minute, String period) {
    return '$h:$minute $period';
  }

  @override
  String dateFormatLong(int year, int month, int day, String weekday) {
    return '$month/$day/$year ($weekday)';
  }
}
