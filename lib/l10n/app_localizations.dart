import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('ja'),
    Locale('ko'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'BebeTap'**
  String get appName;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabStatistics.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get tabStatistics;

  /// No description provided for @tabLog.
  ///
  /// In en, this message translates to:
  /// **'Log'**
  String get tabLog;

  /// No description provided for @tabFamily.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get tabFamily;

  /// No description provided for @menuBabyManage.
  ///
  /// In en, this message translates to:
  /// **'Baby Management'**
  String get menuBabyManage;

  /// No description provided for @menuWidgetAdd.
  ///
  /// In en, this message translates to:
  /// **'Add Widget'**
  String get menuWidgetAdd;

  /// No description provided for @menuIconSettings.
  ///
  /// In en, this message translates to:
  /// **'Icon Settings'**
  String get menuIconSettings;

  /// No description provided for @menuTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get menuTheme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeScheduled.
  ///
  /// In en, this message translates to:
  /// **'Scheduled'**
  String get themeScheduled;

  /// No description provided for @themeScheduleStart.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get themeScheduleStart;

  /// No description provided for @themeScheduleEnd.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get themeScheduleEnd;

  /// No description provided for @menuLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menuLanguage;

  /// No description provided for @menuLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get menuLogout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}!'**
  String homeGreeting(String name);

  /// No description provided for @homeEncouragement.
  ///
  /// In en, this message translates to:
  /// **'Parenting is hard, but you\'re doing amazing! 💛'**
  String get homeEncouragement;

  /// No description provided for @sectionRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get sectionRecord;

  /// No description provided for @formula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get formula;

  /// No description provided for @breast.
  ///
  /// In en, this message translates to:
  /// **'Breastfeed'**
  String get breast;

  /// No description provided for @pumped.
  ///
  /// In en, this message translates to:
  /// **'Pumped'**
  String get pumped;

  /// No description provided for @babyFood.
  ///
  /// In en, this message translates to:
  /// **'Baby Food'**
  String get babyFood;

  /// No description provided for @diaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get diaper;

  /// No description provided for @sleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleep;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get temperature;

  /// No description provided for @growth.
  ///
  /// In en, this message translates to:
  /// **'Growth'**
  String get growth;

  /// No description provided for @diary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diary;

  /// No description provided for @statsFormulaLabel.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get statsFormulaLabel;

  /// No description provided for @statsSleepLabel.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get statsSleepLabel;

  /// No description provided for @statsDiaperLabel.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get statsDiaperLabel;

  /// No description provided for @tapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap to record'**
  String get tapToRecord;

  /// No description provided for @formulaBottomSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Formula Feeding'**
  String get formulaBottomSheetTitle;

  /// No description provided for @breastBottomSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Breastfeeding'**
  String get breastBottomSheetTitle;

  /// No description provided for @pumpedBottomSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Pumped Feeding'**
  String get pumpedBottomSheetTitle;

  /// No description provided for @babyFoodBottomSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Food Record'**
  String get babyFoodBottomSheetTitle;

  /// No description provided for @temperatureRecordTitle.
  ///
  /// In en, this message translates to:
  /// **'Temperature Record'**
  String get temperatureRecordTitle;

  /// No description provided for @diaryWriteTitle.
  ///
  /// In en, this message translates to:
  /// **'Write Diary'**
  String get diaryWriteTitle;

  /// No description provided for @diaryEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Diary'**
  String get diaryEditTitle;

  /// No description provided for @diaryDoneToday.
  ///
  /// In en, this message translates to:
  /// **'Written today'**
  String get diaryDoneToday;

  /// No description provided for @sleepActive.
  ///
  /// In en, this message translates to:
  /// **'Sleeping'**
  String get sleepActive;

  /// No description provided for @lastFeeding.
  ///
  /// In en, this message translates to:
  /// **'Last feeding'**
  String get lastFeeding;

  /// No description provided for @formulaTotal.
  ///
  /// In en, this message translates to:
  /// **'Formula total'**
  String get formulaTotal;

  /// No description provided for @noRecord.
  ///
  /// In en, this message translates to:
  /// **'No records yet'**
  String get noRecord;

  /// No description provided for @startRecordingHint.
  ///
  /// In en, this message translates to:
  /// **'Tap the feeding tile to start'**
  String get startRecordingHint;

  /// No description provided for @typeBreastFeeding.
  ///
  /// In en, this message translates to:
  /// **'Breastfeeding'**
  String get typeBreastFeeding;

  /// No description provided for @typePumpedFeeding.
  ///
  /// In en, this message translates to:
  /// **'Pumped'**
  String get typePumpedFeeding;

  /// No description provided for @typeBabyFood.
  ///
  /// In en, this message translates to:
  /// **'Baby Food'**
  String get typeBabyFood;

  /// No description provided for @typeFormulaFeeding.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get typeFormulaFeeding;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @weekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekdayMon;

  /// No description provided for @weekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekdayTue;

  /// No description provided for @weekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekdayWed;

  /// No description provided for @weekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekdayThu;

  /// No description provided for @weekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekdayFri;

  /// No description provided for @weekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekdaySat;

  /// No description provided for @weekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekdaySun;

  /// No description provided for @dateFormatMonthDay.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}'**
  String dateFormatMonthDay(int month, int day);

  /// No description provided for @dateFormatFull.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day} ({weekday})'**
  String dateFormatFull(int month, int day, String weekday);

  /// No description provided for @dateFormatTodayNav.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day} ({weekday})  Today'**
  String dateFormatTodayNav(int month, int day, String weekday);

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Entry'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete this entry?'**
  String get deleteConfirmMessage;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @saveAmountMl.
  ///
  /// In en, this message translates to:
  /// **'Save {amount}'**
  String saveAmountMl(String amount);

  /// No description provided for @editAmountMl.
  ///
  /// In en, this message translates to:
  /// **'Edit {amount}'**
  String editAmountMl(String amount);

  /// No description provided for @formulaRecommendation.
  ///
  /// In en, this message translates to:
  /// **'{weight}kg → recommended {ml}ml/day'**
  String formulaRecommendation(String weight, int ml);

  /// No description provided for @formulaWeightHint.
  ///
  /// In en, this message translates to:
  /// **'Enter baby weight to see recommendation'**
  String get formulaWeightHint;

  /// No description provided for @todayAmount.
  ///
  /// In en, this message translates to:
  /// **'Today {amount}'**
  String todayAmount(String amount);

  /// No description provided for @menuVolumeUnit.
  ///
  /// In en, this message translates to:
  /// **'Volume Unit'**
  String get menuVolumeUnit;

  /// No description provided for @volumeUnitMl.
  ///
  /// In en, this message translates to:
  /// **'Milliliter (ml)'**
  String get volumeUnitMl;

  /// No description provided for @volumeUnitOz.
  ///
  /// In en, this message translates to:
  /// **'Ounce (oz)'**
  String get volumeUnitOz;

  /// No description provided for @todayCount.
  ///
  /// In en, this message translates to:
  /// **'Today {count} times'**
  String todayCount(int count);

  /// No description provided for @todayDuration.
  ///
  /// In en, this message translates to:
  /// **'Today {duration}'**
  String todayDuration(String duration);

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @minuteUnit.
  ///
  /// In en, this message translates to:
  /// **'{min}min'**
  String minuteUnit(int min);

  /// No description provided for @diaperSelectType.
  ///
  /// In en, this message translates to:
  /// **'Select diaper type'**
  String get diaperSelectType;

  /// No description provided for @diaperWet.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get diaperWet;

  /// No description provided for @diaperSoiled.
  ///
  /// In en, this message translates to:
  /// **'Soiled'**
  String get diaperSoiled;

  /// No description provided for @diaperBoth.
  ///
  /// In en, this message translates to:
  /// **'Wet+Soiled'**
  String get diaperBoth;

  /// No description provided for @diaperChange.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get diaperChange;

  /// No description provided for @sleepEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit Sleep'**
  String get sleepEdit;

  /// No description provided for @sleepRecord.
  ///
  /// In en, this message translates to:
  /// **'Record Sleep'**
  String get sleepRecord;

  /// No description provided for @sleepStart.
  ///
  /// In en, this message translates to:
  /// **'Start Sleep'**
  String get sleepStart;

  /// No description provided for @sleepEnd.
  ///
  /// In en, this message translates to:
  /// **'End Sleep'**
  String get sleepEnd;

  /// No description provided for @sleepHint.
  ///
  /// In en, this message translates to:
  /// **'Timer starts when sleep begins.\nRecords are kept even when app is closed.'**
  String get sleepHint;

  /// No description provided for @sleepEndTimeError.
  ///
  /// In en, this message translates to:
  /// **'End time cannot be before start time'**
  String get sleepEndTimeError;

  /// No description provided for @startTime.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startTime;

  /// No description provided for @endTime.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get endTime;

  /// No description provided for @startHourMinute.
  ///
  /// In en, this message translates to:
  /// **'{hour}:{minute}'**
  String startHourMinute(int hour, String minute);

  /// No description provided for @measureMethod.
  ///
  /// In en, this message translates to:
  /// **'Measurement method'**
  String get measureMethod;

  /// No description provided for @methodAxillary.
  ///
  /// In en, this message translates to:
  /// **'Axillary'**
  String get methodAxillary;

  /// No description provided for @methodEar.
  ///
  /// In en, this message translates to:
  /// **'Ear'**
  String get methodEar;

  /// No description provided for @methodForehead.
  ///
  /// In en, this message translates to:
  /// **'Forehead'**
  String get methodForehead;

  /// No description provided for @methodRectal.
  ///
  /// In en, this message translates to:
  /// **'Rectal'**
  String get methodRectal;

  /// No description provided for @highFeverWarning.
  ///
  /// In en, this message translates to:
  /// **'High fever. Consult a doctor immediately.'**
  String get highFeverWarning;

  /// No description provided for @lowFeverWarning.
  ///
  /// In en, this message translates to:
  /// **'Low fever. Monitor closely.'**
  String get lowFeverWarning;

  /// No description provided for @diaryTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Enter title'**
  String get diaryTitleHint;

  /// No description provided for @diaryContentHint.
  ///
  /// In en, this message translates to:
  /// **'Write about your day with baby...'**
  String get diaryContentHint;

  /// No description provided for @diaryAuthorLabel.
  ///
  /// In en, this message translates to:
  /// **'Author'**
  String get diaryAuthorLabel;

  /// No description provided for @diaryReadOnly.
  ///
  /// In en, this message translates to:
  /// **'This diary belongs to another author and cannot be edited.'**
  String get diaryReadOnly;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Parenting record app for new parents'**
  String get loginSubtitle;

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

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @signupWithEmail.
  ///
  /// In en, this message translates to:
  /// **'Sign up with email'**
  String get signupWithEmail;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @orSocialLogin.
  ///
  /// In en, this message translates to:
  /// **'Or social login'**
  String get orSocialLogin;

  /// No description provided for @continueWithGoogle.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithKakao.
  ///
  /// In en, this message translates to:
  /// **'Continue with Kakao'**
  String get continueWithKakao;

  /// No description provided for @continueWithFacebook.
  ///
  /// In en, this message translates to:
  /// **'Continue with Facebook'**
  String get continueWithFacebook;

  /// No description provided for @continueWithLine.
  ///
  /// In en, this message translates to:
  /// **'Continue with Line'**
  String get continueWithLine;

  /// No description provided for @invalidEmailPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get invalidEmailPassword;

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'Network error. Please try again.'**
  String get networkError;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed: {error}'**
  String loginFailed(String error);

  /// No description provided for @passwordReset.
  ///
  /// In en, this message translates to:
  /// **'Password Reset'**
  String get passwordReset;

  /// No description provided for @emailAddressLabel.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddressLabel;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @resetEmailSent.
  ///
  /// In en, this message translates to:
  /// **'Password reset email has been sent.'**
  String get resetEmailSent;

  /// No description provided for @sendFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed: {error}'**
  String sendFailed(String error);

  /// No description provided for @emailSignupTitle.
  ///
  /// In en, this message translates to:
  /// **'Email Sign Up'**
  String get emailSignupTitle;

  /// No description provided for @enterEmailPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address to sign up'**
  String get enterEmailPrompt;

  /// No description provided for @sendVerification.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Email'**
  String get sendVerification;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Login'**
  String get alreadyHaveAccount;

  /// No description provided for @setPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Password'**
  String get setPasswordTitle;

  /// No description provided for @setPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'You will use this email and password for future logins'**
  String get setPasswordHint;

  /// No description provided for @passwordInput.
  ///
  /// In en, this message translates to:
  /// **'Password (6+ characters)'**
  String get passwordInput;

  /// No description provided for @passwordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get passwordConfirm;

  /// No description provided for @enterOtpTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter Verification Code'**
  String get enterOtpTitle;

  /// No description provided for @enterOtpHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your email'**
  String get enterOtpHint;

  /// No description provided for @completeSignup.
  ///
  /// In en, this message translates to:
  /// **'Complete Sign Up'**
  String get completeSignup;

  /// No description provided for @resendEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendEmail;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get invalidEmail;

  /// No description provided for @emailAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'Email already registered. Redirecting to login.'**
  String get emailAlreadyExists;

  /// No description provided for @sendOtpFailed.
  ///
  /// In en, this message translates to:
  /// **'Send failed: {error}'**
  String sendOtpFailed(String error);

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordMismatch;

  /// No description provided for @enterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 6-digit code'**
  String get enterSixDigitCode;

  /// No description provided for @signupFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign up failed: {error}'**
  String signupFailed(String error);

  /// No description provided for @resendSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification code resent.'**
  String get resendSuccess;

  /// No description provided for @resendFailed.
  ///
  /// In en, this message translates to:
  /// **'Resend failed: {error}'**
  String resendFailed(String error);

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @babyManageTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Management'**
  String get babyManageTitle;

  /// No description provided for @registeredBabies.
  ///
  /// In en, this message translates to:
  /// **'Registered babies'**
  String get registeredBabies;

  /// No description provided for @addNewBaby.
  ///
  /// In en, this message translates to:
  /// **'Add new baby'**
  String get addNewBaby;

  /// No description provided for @babyName.
  ///
  /// In en, this message translates to:
  /// **'Baby Name *'**
  String get babyName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date *'**
  String get birthDate;

  /// No description provided for @genderOptional.
  ///
  /// In en, this message translates to:
  /// **'Gender (optional)'**
  String get genderOptional;

  /// No description provided for @boy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get boy;

  /// No description provided for @girl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get girl;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight kg (optional)'**
  String get currentWeight;

  /// No description provided for @photoSelect.
  ///
  /// In en, this message translates to:
  /// **'Select photo (optional)'**
  String get photoSelect;

  /// No description provided for @selectBirthDate.
  ///
  /// In en, this message translates to:
  /// **'Select a date'**
  String get selectBirthDate;

  /// No description provided for @birthDatePrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select a birth date'**
  String get birthDatePrompt;

  /// No description provided for @babyNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. John'**
  String get babyNameHint;

  /// No description provided for @babyNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get babyNameRequired;

  /// No description provided for @invalidWeight.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid weight (0~30 kg)'**
  String get invalidWeight;

  /// No description provided for @weightHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 4.5'**
  String get weightHint;

  /// No description provided for @weightFormulaHint.
  ///
  /// In en, this message translates to:
  /// **'Entering weight calculates daily formula recommendation'**
  String get weightFormulaHint;

  /// No description provided for @babyRelationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship with baby *'**
  String get babyRelationship;

  /// No description provided for @or.
  ///
  /// In en, this message translates to:
  /// **'Or'**
  String get or;

  /// No description provided for @joinWithInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Join with invite code'**
  String get joinWithInviteCode;

  /// No description provided for @selectBaby.
  ///
  /// In en, this message translates to:
  /// **'Select Baby'**
  String get selectBaby;

  /// No description provided for @babySetupTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Information'**
  String get babySetupTitle;

  /// No description provided for @babyEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Baby'**
  String get babyEditTitle;

  /// No description provided for @babyAddTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Baby'**
  String get babyAddTitle;

  /// No description provided for @addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get addButton;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @noFamilyFound.
  ///
  /// In en, this message translates to:
  /// **'Family information not found'**
  String get noFamilyFound;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveFailed(String error);

  /// No description provided for @loadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed: {error}'**
  String loadFailed(String error);

  /// No description provided for @babyRelationshipPrompt.
  ///
  /// In en, this message translates to:
  /// **'Please select your relationship with baby'**
  String get babyRelationshipPrompt;

  /// No description provided for @startButton.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get startButton;

  /// No description provided for @dateFormat.
  ///
  /// In en, this message translates to:
  /// **'yyyy/MM/dd'**
  String get dateFormat;

  /// No description provided for @relationMom.
  ///
  /// In en, this message translates to:
  /// **'Mom'**
  String get relationMom;

  /// No description provided for @relationDad.
  ///
  /// In en, this message translates to:
  /// **'Dad'**
  String get relationDad;

  /// No description provided for @relationGrandma.
  ///
  /// In en, this message translates to:
  /// **'Grandma'**
  String get relationGrandma;

  /// No description provided for @relationGrandpa.
  ///
  /// In en, this message translates to:
  /// **'Grandpa'**
  String get relationGrandpa;

  /// No description provided for @relationAunt.
  ///
  /// In en, this message translates to:
  /// **'Aunt'**
  String get relationAunt;

  /// No description provided for @relationUncle.
  ///
  /// In en, this message translates to:
  /// **'Uncle'**
  String get relationUncle;

  /// No description provided for @relationPaternalAunt.
  ///
  /// In en, this message translates to:
  /// **'Paternal Aunt'**
  String get relationPaternalAunt;

  /// No description provided for @relationMaternalUncle.
  ///
  /// In en, this message translates to:
  /// **'Maternal Uncle'**
  String get relationMaternalUncle;

  /// No description provided for @relationCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get relationCustom;

  /// No description provided for @relationCustomHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Stepmother, Nanny'**
  String get relationCustomHint;

  /// No description provided for @familyTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Sharing'**
  String get familyTitle;

  /// No description provided for @familyGroupName.
  ///
  /// In en, this message translates to:
  /// **'Family name'**
  String get familyGroupName;

  /// No description provided for @familyNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Smith family'**
  String get familyNameHint;

  /// No description provided for @createFamilyDialog.
  ///
  /// In en, this message translates to:
  /// **'Create Family Group'**
  String get createFamilyDialog;

  /// No description provided for @makeFamily.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get makeFamily;

  /// No description provided for @createFamily.
  ///
  /// In en, this message translates to:
  /// **'Create new family group'**
  String get createFamily;

  /// No description provided for @noFamily.
  ///
  /// In en, this message translates to:
  /// **'No family group'**
  String get noFamily;

  /// No description provided for @noFamilyHint.
  ///
  /// In en, this message translates to:
  /// **'Create a family or join with invite code'**
  String get noFamilyHint;

  /// No description provided for @inviteCode.
  ///
  /// In en, this message translates to:
  /// **'Invite code'**
  String get inviteCode;

  /// No description provided for @inviteCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Invite code copied'**
  String get inviteCodeCopied;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @inviteCodeShareHint.
  ///
  /// In en, this message translates to:
  /// **'Share this code with family to record together'**
  String get inviteCodeShareHint;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family members'**
  String get familyMembers;

  /// No description provided for @familyError.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get familyError;

  /// No description provided for @joinFamily.
  ///
  /// In en, this message translates to:
  /// **'Join with invite code'**
  String get joinFamily;

  /// No description provided for @enterInviteCode.
  ///
  /// In en, this message translates to:
  /// **'Enter invite code'**
  String get enterInviteCode;

  /// No description provided for @relationshipLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship with baby'**
  String get relationshipLabel;

  /// No description provided for @joinButton.
  ///
  /// In en, this message translates to:
  /// **'Join Family'**
  String get joinButton;

  /// No description provided for @enterInviteCodeError.
  ///
  /// In en, this message translates to:
  /// **'Please enter an invite code'**
  String get enterInviteCodeError;

  /// No description provided for @selectRelationshipError.
  ///
  /// In en, this message translates to:
  /// **'Please select your relationship with baby'**
  String get selectRelationshipError;

  /// No description provided for @me.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get me;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get userLabel;

  /// No description provided for @caregiverRole.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get caregiverRole;

  /// No description provided for @familyRole.
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get familyRole;

  /// No description provided for @familyLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Load failed'**
  String get familyLoadFailed;

  /// No description provided for @familyShareMessage.
  ///
  /// In en, this message translates to:
  /// **'Join {familyName} on BebeTap!\nInvite code: {code}'**
  String familyShareMessage(String familyName, String code);

  /// No description provided for @familyShareSubject.
  ///
  /// In en, this message translates to:
  /// **'BebeTap Family Invite'**
  String get familyShareSubject;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @sleepSection.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get sleepSection;

  /// No description provided for @totalSleep.
  ///
  /// In en, this message translates to:
  /// **'Total sleep'**
  String get totalSleep;

  /// No description provided for @feedingSection.
  ///
  /// In en, this message translates to:
  /// **'Feeding'**
  String get feedingSection;

  /// No description provided for @noFeedingRecord.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get noFeedingRecord;

  /// No description provided for @diaperSection.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get diaperSection;

  /// No description provided for @diaperChangeLabel.
  ///
  /// In en, this message translates to:
  /// **'Diaper change'**
  String get diaperChangeLabel;

  /// No description provided for @timesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} times'**
  String timesCount(int count);

  /// No description provided for @diaryCountUnit.
  ///
  /// In en, this message translates to:
  /// **'{count} entries'**
  String diaryCountUnit(int count);

  /// No description provided for @dataLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Cannot load data'**
  String get dataLoadFailed;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// No description provided for @periodMonth.
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get periodMonth;

  /// No description provided for @period3Months.
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get period3Months;

  /// No description provided for @period6Months.
  ///
  /// In en, this message translates to:
  /// **'6 Months'**
  String get period6Months;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @lifePattern.
  ///
  /// In en, this message translates to:
  /// **'Life Pattern'**
  String get lifePattern;

  /// No description provided for @lifePatternTip.
  ///
  /// In en, this message translates to:
  /// **'💡 Tap an icon to filter and view only that category'**
  String get lifePatternTip;

  /// No description provided for @feedingStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Feeding Stats'**
  String get feedingStatsTitle;

  /// No description provided for @babyFoodStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Baby Food Stats'**
  String get babyFoodStatsTitle;

  /// No description provided for @sleepStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sleep Stats'**
  String get sleepStatsTitle;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @totalBabyFood.
  ///
  /// In en, this message translates to:
  /// **'Total Baby Food'**
  String get totalBabyFood;

  /// No description provided for @babyFoodCount.
  ///
  /// In en, this message translates to:
  /// **'Baby Food Count'**
  String get babyFoodCount;

  /// No description provided for @noBabyFoodRecord.
  ///
  /// In en, this message translates to:
  /// **'No baby food records'**
  String get noBabyFoodRecord;

  /// No description provided for @dailyBabyFoodTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily Baby Food Trend'**
  String get dailyBabyFoodTrend;

  /// No description provided for @logTitle.
  ///
  /// In en, this message translates to:
  /// **'Parenting Log'**
  String get logTitle;

  /// No description provided for @logLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load records'**
  String get logLoadFailed;

  /// No description provided for @noLogForDay.
  ///
  /// In en, this message translates to:
  /// **'No records for this day'**
  String get noLogForDay;

  /// No description provided for @addLogHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add a record'**
  String get addLogHint;

  /// No description provided for @editFormula.
  ///
  /// In en, this message translates to:
  /// **'Edit Formula'**
  String get editFormula;

  /// No description provided for @editPumped.
  ///
  /// In en, this message translates to:
  /// **'Edit Pumped'**
  String get editPumped;

  /// No description provided for @editBabyFood.
  ///
  /// In en, this message translates to:
  /// **'Edit Baby Food'**
  String get editBabyFood;

  /// No description provided for @editBreast.
  ///
  /// In en, this message translates to:
  /// **'Edit Breastfeeding'**
  String get editBreast;

  /// No description provided for @editDiaper.
  ///
  /// In en, this message translates to:
  /// **'Edit Diaper'**
  String get editDiaper;

  /// No description provided for @editSleep.
  ///
  /// In en, this message translates to:
  /// **'Edit Sleep'**
  String get editSleep;

  /// No description provided for @editTemperature.
  ///
  /// In en, this message translates to:
  /// **'Edit Temperature'**
  String get editTemperature;

  /// No description provided for @diaryLog.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get diaryLog;

  /// No description provided for @addFormula.
  ///
  /// In en, this message translates to:
  /// **'Formula Feeding'**
  String get addFormula;

  /// No description provided for @addPumped.
  ///
  /// In en, this message translates to:
  /// **'Pumped Feeding'**
  String get addPumped;

  /// No description provided for @addBabyFood.
  ///
  /// In en, this message translates to:
  /// **'Baby Food'**
  String get addBabyFood;

  /// No description provided for @addBreast.
  ///
  /// In en, this message translates to:
  /// **'Breastfeeding'**
  String get addBreast;

  /// No description provided for @addDiaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get addDiaper;

  /// No description provided for @addSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get addSleep;

  /// No description provided for @addTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get addTemperature;

  /// No description provided for @editDiary.
  ///
  /// In en, this message translates to:
  /// **'Edit Diary'**
  String get editDiary;

  /// No description provided for @writeDiary.
  ///
  /// In en, this message translates to:
  /// **'Write Diary'**
  String get writeDiary;

  /// No description provided for @entryFormula.
  ///
  /// In en, this message translates to:
  /// **'Formula'**
  String get entryFormula;

  /// No description provided for @entryBreast.
  ///
  /// In en, this message translates to:
  /// **'Breastfeed'**
  String get entryBreast;

  /// No description provided for @entryPumped.
  ///
  /// In en, this message translates to:
  /// **'Pumped'**
  String get entryPumped;

  /// No description provided for @entryBabyFood.
  ///
  /// In en, this message translates to:
  /// **'Baby Food'**
  String get entryBabyFood;

  /// No description provided for @entrySleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep'**
  String get entrySleep;

  /// No description provided for @entrySleeping.
  ///
  /// In en, this message translates to:
  /// **'Sleeping'**
  String get entrySleeping;

  /// No description provided for @entryDiaper.
  ///
  /// In en, this message translates to:
  /// **'Diaper'**
  String get entryDiaper;

  /// No description provided for @entryTemperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get entryTemperature;

  /// No description provided for @durationSeconds.
  ///
  /// In en, this message translates to:
  /// **'{s}s'**
  String durationSeconds(int s);

  /// No description provided for @durationMinutesOnly.
  ///
  /// In en, this message translates to:
  /// **'{m}m'**
  String durationMinutesOnly(int m);

  /// No description provided for @durationHoursOnly.
  ///
  /// In en, this message translates to:
  /// **'{h}h'**
  String durationHoursOnly(int h);

  /// No description provided for @durationHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m'**
  String durationHoursMinutes(int h, int m);

  /// No description provided for @elapsedJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get elapsedJustNow;

  /// No description provided for @elapsedMinutes.
  ///
  /// In en, this message translates to:
  /// **'{m}min ago'**
  String elapsedMinutes(int m);

  /// No description provided for @elapsedHoursOnly.
  ///
  /// In en, this message translates to:
  /// **'{h}h ago'**
  String elapsedHoursOnly(int h);

  /// No description provided for @elapsedHoursMinutes.
  ///
  /// In en, this message translates to:
  /// **'{h}h {m}m ago'**
  String elapsedHoursMinutes(int h, int m);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @iconSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Icon Settings'**
  String get iconSettingsTitle;

  /// No description provided for @iconSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder, toggle to show/hide.'**
  String get iconSettingsHint;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @pickerToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get pickerToday;

  /// No description provided for @pickerHour.
  ///
  /// In en, this message translates to:
  /// **'h'**
  String get pickerHour;

  /// No description provided for @pickerMinute.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get pickerMinute;

  /// No description provided for @pickerConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get pickerConfirm;

  /// No description provided for @displayTime.
  ///
  /// In en, this message translates to:
  /// **'{h}:{minute} {period}'**
  String displayTime(int h, String minute, String period);

  /// No description provided for @dateFormatLong.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}/{year} ({weekday})'**
  String dateFormatLong(int year, int month, int day, String weekday);

  /// No description provided for @napSleep.
  ///
  /// In en, this message translates to:
  /// **'Nap'**
  String get napSleep;

  /// No description provided for @nightSleep.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get nightSleep;

  /// No description provided for @napVsNight.
  ///
  /// In en, this message translates to:
  /// **'Nap vs Night'**
  String get napVsNight;

  /// No description provided for @dailySleepTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily sleep trend'**
  String get dailySleepTrend;

  /// No description provided for @longestSleep.
  ///
  /// In en, this message translates to:
  /// **'Longest sleep'**
  String get longestSleep;

  /// No description provided for @bedtimeConsistency.
  ///
  /// In en, this message translates to:
  /// **'Bedtime consistency'**
  String get bedtimeConsistency;

  /// No description provided for @avgDailySleep.
  ///
  /// In en, this message translates to:
  /// **'Avg daily sleep'**
  String get avgDailySleep;

  /// No description provided for @belowRecommended.
  ///
  /// In en, this message translates to:
  /// **'Below recommended'**
  String get belowRecommended;

  /// No description provided for @aboveRecommended.
  ///
  /// In en, this message translates to:
  /// **'Above recommended'**
  String get aboveRecommended;

  /// No description provided for @withinRecommended.
  ///
  /// In en, this message translates to:
  /// **'Within range'**
  String get withinRecommended;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @avgFeedingInterval.
  ///
  /// In en, this message translates to:
  /// **'Avg interval'**
  String get avgFeedingInterval;

  /// No description provided for @dailyIntakeTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily intake trend'**
  String get dailyIntakeTrend;

  /// No description provided for @leftRightBalance.
  ///
  /// In en, this message translates to:
  /// **'Left / Right balance'**
  String get leftRightBalance;

  /// No description provided for @leftBreast.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get leftBreast;

  /// No description provided for @rightBreast.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get rightBreast;

  /// No description provided for @wetDiaper.
  ///
  /// In en, this message translates to:
  /// **'Wet'**
  String get wetDiaper;

  /// No description provided for @soiledDiaper.
  ///
  /// In en, this message translates to:
  /// **'Soiled'**
  String get soiledDiaper;

  /// No description provided for @bothDiaper.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get bothDiaper;

  /// No description provided for @dailyDiaperTrend.
  ///
  /// In en, this message translates to:
  /// **'Daily diaper trend'**
  String get dailyDiaperTrend;

  /// No description provided for @healthSection.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get healthSection;

  /// No description provided for @avgLabel.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get avgLabel;

  /// No description provided for @temperatureTrend.
  ///
  /// In en, this message translates to:
  /// **'Temperature trend'**
  String get temperatureTrend;

  /// No description provided for @dailyRoutine.
  ///
  /// In en, this message translates to:
  /// **'Daily routine'**
  String get dailyRoutine;

  /// No description provided for @heatmapLow.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get heatmapLow;

  /// No description provided for @heatmapHigh.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get heatmapHigh;

  /// No description provided for @insightsSection.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsSection;

  /// No description provided for @insightFeedingPredictionBody.
  ///
  /// In en, this message translates to:
  /// **'Baby may be hungry in about {minutes} minutes'**
  String insightFeedingPredictionBody(String minutes);

  /// No description provided for @insightNapPredictionBody.
  ///
  /// In en, this message translates to:
  /// **'Based on pattern, next nap in ~{minutes} minutes'**
  String insightNapPredictionBody(String minutes);

  /// No description provided for @insightIntakeDropBody.
  ///
  /// In en, this message translates to:
  /// **'Formula intake dropped {percent}% over the last 3 days'**
  String insightIntakeDropBody(String percent);

  /// No description provided for @insightLowWetDiapersBody.
  ///
  /// In en, this message translates to:
  /// **'Only {count} wet diapers in last 24h — check hydration'**
  String insightLowWetDiapersBody(String count);

  /// No description provided for @insightFeverBody.
  ///
  /// In en, this message translates to:
  /// **'Latest temperature {temp}°C is above normal range'**
  String insightFeverBody(String temp);

  /// No description provided for @insightSleepRegressionBody.
  ///
  /// In en, this message translates to:
  /// **'Total sleep dropped {percent}% compared to last week'**
  String insightSleepRegressionBody(String percent);

  /// No description provided for @insightNapNightCorrelationBody.
  ///
  /// In en, this message translates to:
  /// **'Less daytime napping tends to mean more night wakings'**
  String get insightNapNightCorrelationBody;

  /// No description provided for @babyComparison.
  ///
  /// In en, this message translates to:
  /// **'Compare'**
  String get babyComparison;

  /// No description provided for @comparisonAge.
  ///
  /// In en, this message translates to:
  /// **'Age to compare'**
  String get comparisonAge;

  /// No description provided for @daysLabel.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get daysLabel;

  /// No description provided for @monthsLabel.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get monthsLabel;

  /// No description provided for @comparisonNeedTwoBabies.
  ///
  /// In en, this message translates to:
  /// **'Register 2 or more babies to compare'**
  String get comparisonNeedTwoBabies;

  /// No description provided for @babyAgeDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days old'**
  String babyAgeDays(int count);

  /// No description provided for @babyAgeMonths.
  ///
  /// In en, this message translates to:
  /// **'{months} months'**
  String babyAgeMonths(int months);

  /// No description provided for @babyAgeMonthsDays.
  ///
  /// In en, this message translates to:
  /// **'{months}m {days}d'**
  String babyAgeMonthsDays(int months, int days);
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
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
