// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appName => 'BebeTap';

  @override
  String get tabHome => '홈';

  @override
  String get tabStatistics => '통계';

  @override
  String get tabLog => '기록';

  @override
  String get tabFamily => '가족';

  @override
  String get menuBabyManage => '아이 관리';

  @override
  String get menuWidgetAdd => '위젯 추가';

  @override
  String get menuIconSettings => '아이콘 설정';

  @override
  String get menuTheme => '테마 설정';

  @override
  String get themeLight => '라이트';

  @override
  String get themeDark => '다크';

  @override
  String get themeSystem => '시스템';

  @override
  String get themeScheduled => '예약';

  @override
  String get themeScheduleStart => '시작';

  @override
  String get themeScheduleEnd => '종료';

  @override
  String get menuLanguage => '언어 설정';

  @override
  String get menuLogout => '로그아웃';

  @override
  String get logoutConfirmTitle => '로그아웃';

  @override
  String get logoutConfirmMessage => '로그아웃 하시겠어요?';

  @override
  String get cancel => '취소';

  @override
  String get comingSoon => '준비 중입니다';

  @override
  String homeGreeting(String name) {
    return '안녕, $name!';
  }

  @override
  String get homeEncouragement => '아기도 힘들지만 엄마 아빠도\n정말 수고하고 있을 거예요 💛';

  @override
  String get sectionRecord => '기록하기';

  @override
  String get formula => '분유';

  @override
  String get breast => '모유';

  @override
  String get pumped => '유축수유';

  @override
  String get babyFood => '이유식';

  @override
  String get diaper => '기저귀';

  @override
  String get sleep => '수면';

  @override
  String get temperature => '체온';

  @override
  String get growth => '성장';

  @override
  String get diary => '일기';

  @override
  String get statsFormulaLabel => '분유';

  @override
  String get statsSleepLabel => '수면';

  @override
  String get statsDiaperLabel => '기저귀';

  @override
  String get tapToRecord => '탭해서 기록';

  @override
  String get formulaBottomSheetTitle => '분유 수유';

  @override
  String get breastBottomSheetTitle => '모유 수유';

  @override
  String get pumpedBottomSheetTitle => '유축 수유';

  @override
  String get babyFoodBottomSheetTitle => '이유식 기록';

  @override
  String get temperatureRecordTitle => '체온 기록';

  @override
  String get diaryWriteTitle => '일기 쓰기';

  @override
  String get diaryEditTitle => '일기 수정';

  @override
  String get diaryDoneToday => '오늘 작성 완료';

  @override
  String get sleepActive => '수면 중';

  @override
  String get lastFeeding => '마지막 수유';

  @override
  String get formulaTotal => '분유 총량';

  @override
  String get noRecord => '아직 기록이 없어요';

  @override
  String get startRecordingHint => '수유 타일을 눌러 시작하세요';

  @override
  String get typeBreastFeeding => '모유 수유';

  @override
  String get typePumpedFeeding => '유축 수유';

  @override
  String get typeBabyFood => '이유식';

  @override
  String get typeFormulaFeeding => '분유 수유';

  @override
  String get today => '오늘';

  @override
  String get yesterday => '어제';

  @override
  String get am => '오전';

  @override
  String get pm => '오후';

  @override
  String get weekdayMon => '월';

  @override
  String get weekdayTue => '화';

  @override
  String get weekdayWed => '수';

  @override
  String get weekdayThu => '목';

  @override
  String get weekdayFri => '금';

  @override
  String get weekdaySat => '토';

  @override
  String get weekdaySun => '일';

  @override
  String dateFormatMonthDay(int month, int day) {
    return '$month월 $day일';
  }

  @override
  String dateFormatFull(int month, int day, String weekday) {
    return '$month월 $day일 ($weekday)';
  }

  @override
  String dateFormatTodayNav(int month, int day, String weekday) {
    return '$month월 $day일 ($weekday)  오늘';
  }

  @override
  String get save => '저장';

  @override
  String get edit => '수정';

  @override
  String get confirm => '확인';

  @override
  String saveAmountMl(String amount) {
    return '$amount 저장';
  }

  @override
  String editAmountMl(String amount) {
    return '$amount 수정';
  }

  @override
  String formulaRecommendation(String weight, int ml) {
    return '${weight}kg 기준 권장량 ${ml}ml/일';
  }

  @override
  String get formulaWeightHint => '아기 몸무게를 등록하면 권장량을 알 수 있어요';

  @override
  String todayAmount(String amount) {
    return '오늘 $amount';
  }

  @override
  String get menuVolumeUnit => '단위 설정';

  @override
  String get volumeUnitMl => '밀리리터 (ml)';

  @override
  String get volumeUnitOz => '온스 (oz)';

  @override
  String todayCount(int count) {
    return '오늘 $count회';
  }

  @override
  String todayDuration(String duration) {
    return '오늘 $duration';
  }

  @override
  String get left => '왼쪽';

  @override
  String get right => '오른쪽';

  @override
  String minuteUnit(int min) {
    return '$min분';
  }

  @override
  String get diaperSelectType => '기저귀 종류를 선택하세요';

  @override
  String get diaperWet => '소변';

  @override
  String get diaperSoiled => '대변';

  @override
  String get diaperBoth => '소변+대변';

  @override
  String get diaperChange => '교체';

  @override
  String get sleepEdit => '수면 수정';

  @override
  String get sleepRecord => '수면 기록';

  @override
  String get sleepStart => '수면 시작';

  @override
  String get sleepEnd => '수면 종료';

  @override
  String get sleepHint => '수면을 시작하면 타이머가 작동합니다.\n앱을 종료해도 기록이 유지됩니다.';

  @override
  String get sleepEndTimeError => '종료 시간이 시작 시간보다 이전일 수 없어요';

  @override
  String get startTime => '시작';

  @override
  String get endTime => '종료';

  @override
  String startHourMinute(int hour, String minute) {
    return '$hour시 $minute분';
  }

  @override
  String get measureMethod => '측정 방법';

  @override
  String get methodAxillary => '겨드랑이';

  @override
  String get methodEar => '귀';

  @override
  String get methodForehead => '이마';

  @override
  String get methodRectal => '항문';

  @override
  String get highFeverWarning => '고열입니다. 즉시 의사에게 상담하세요.';

  @override
  String get lowFeverWarning => '미열입니다. 경과를 주의깊게 관찰하세요.';

  @override
  String get diaryTitleHint => '제목을 입력하세요';

  @override
  String get diaryContentHint => '오늘 아기와 함께한 이야기를 적어보세요...';

  @override
  String get diaryAuthorLabel => '작성자';

  @override
  String get diaryReadOnly => '다른 작성자의 일기는 수정할 수 없어요.';

  @override
  String get loginSubtitle => '초보 부모를 위한 육아 기록 앱';

  @override
  String get email => '이메일';

  @override
  String get password => '비밀번호';

  @override
  String get forgotPassword => '비밀번호를 잊으셨나요?';

  @override
  String get signupWithEmail => '이메일로 회원가입';

  @override
  String get login => '로그인';

  @override
  String get orSocialLogin => '또는 소셜 로그인';

  @override
  String get continueWithGoogle => 'Google로 계속하기';

  @override
  String get continueWithKakao => '카카오로 계속하기';

  @override
  String get continueWithFacebook => 'Facebook으로 계속하기';

  @override
  String get continueWithLine => 'Line으로 계속하기';

  @override
  String get invalidEmailPassword => '이메일 또는 비밀번호가 올바르지 않습니다';

  @override
  String get networkError => '네트워크 오류가 발생했습니다. 다시 시도해주세요';

  @override
  String loginFailed(String error) {
    return '로그인 실패: $error';
  }

  @override
  String get passwordReset => '비밀번호 재설정';

  @override
  String get emailAddressLabel => '이메일 주소';

  @override
  String get send => '전송';

  @override
  String get resetEmailSent => '비밀번호 재설정 메일을 발송했습니다.';

  @override
  String sendFailed(String error) {
    return '전송 실패: $error';
  }

  @override
  String get emailSignupTitle => '이메일 회원가입';

  @override
  String get enterEmailPrompt => '가입할 이메일 주소를 입력해주세요';

  @override
  String get sendVerification => '인증 메일 발송';

  @override
  String get alreadyHaveAccount => '이미 계정이 있으신가요? 로그인';

  @override
  String get setPasswordTitle => '비밀번호를 설정해주세요';

  @override
  String get setPasswordHint => '다음 로그인부터 이메일과 비밀번호로 로그인합니다';

  @override
  String get passwordInput => '비밀번호 (6자 이상)';

  @override
  String get passwordConfirm => '비밀번호 확인';

  @override
  String get enterOtpTitle => '인증 코드를 입력해주세요';

  @override
  String get enterOtpHint => '이메일로 발송된 6자리 코드를 입력해주세요';

  @override
  String get completeSignup => '가입 완료';

  @override
  String get resendEmail => '이메일 재발송';

  @override
  String get invalidEmail => '올바른 이메일 형식을 입력해주세요';

  @override
  String get emailAlreadyExists => '이미 가입된 이메일입니다. 로그인 페이지로 이동합니다.';

  @override
  String sendOtpFailed(String error) {
    return '발송 실패: $error';
  }

  @override
  String get passwordTooShort => '비밀번호는 6자 이상이어야 합니다';

  @override
  String get passwordMismatch => '비밀번호가 일치하지 않습니다';

  @override
  String get enterSixDigitCode => '6자리 인증 코드를 입력해주세요';

  @override
  String signupFailed(String error) {
    return '가입 실패: $error';
  }

  @override
  String get resendSuccess => '인증 코드를 재발송했습니다.';

  @override
  String resendFailed(String error) {
    return '재발송 실패: $error';
  }

  @override
  String get next => '다음';

  @override
  String get babyManageTitle => '아이 관리';

  @override
  String get registeredBabies => '등록된 아이';

  @override
  String get addNewBaby => '새 아이 추가';

  @override
  String get babyName => '아기 이름 *';

  @override
  String get birthDate => '생년월일 *';

  @override
  String get genderOptional => '성별 (선택)';

  @override
  String get boy => '남자아이';

  @override
  String get girl => '여자아이';

  @override
  String get currentWeight => '현재 체중 kg (선택)';

  @override
  String get photoSelect => '사진 선택 (선택)';

  @override
  String get selectBirthDate => '날짜를 선택하세요';

  @override
  String get birthDatePrompt => '생년월일을 선택해주세요';

  @override
  String get babyNameHint => '예: 김하늘';

  @override
  String get babyNameRequired => '이름을 입력해주세요';

  @override
  String get invalidWeight => '올바른 체중을 입력해주세요 (0~30 kg)';

  @override
  String get weightHint => '예: 4.5';

  @override
  String get weightFormulaHint => '체중을 입력하면 분유 일일 권장량을 자동으로 계산해드립니다';

  @override
  String get babyRelationship => '아기와의 관계 *';

  @override
  String get or => '또는';

  @override
  String get joinWithInviteCode => '초대 코드로 합류하기';

  @override
  String get selectBaby => '아이 선택';

  @override
  String get babySetupTitle => '아기 정보 입력';

  @override
  String get babyEditTitle => '아이 수정';

  @override
  String get babyAddTitle => '아이 추가';

  @override
  String get addButton => '추가하기';

  @override
  String get editButton => '수정하기';

  @override
  String get noFamilyFound => '가족 정보를 찾을 수 없습니다';

  @override
  String saveFailed(String error) {
    return '저장 실패: $error';
  }

  @override
  String loadFailed(String error) {
    return '불러오기 실패: $error';
  }

  @override
  String get babyRelationshipPrompt => '아기와의 관계를 선택해주세요';

  @override
  String get startButton => '시작하기';

  @override
  String get dateFormat => 'yyyy년 MM월 dd일';

  @override
  String get relationMom => '엄마';

  @override
  String get relationDad => '아빠';

  @override
  String get relationGrandma => '할머니';

  @override
  String get relationGrandpa => '할아버지';

  @override
  String get relationAunt => '이모';

  @override
  String get relationUncle => '삼촌';

  @override
  String get relationPaternalAunt => '고모';

  @override
  String get relationMaternalUncle => '외삼촌';

  @override
  String get relationCustom => '직접입력';

  @override
  String get relationCustomHint => '예: 외할머니, 큰이모';

  @override
  String get familyTitle => '가족 공유';

  @override
  String get familyGroupName => '가족 이름';

  @override
  String get familyNameHint => '예: 김씨 가족';

  @override
  String get createFamilyDialog => '가족 그룹 만들기';

  @override
  String get makeFamily => '만들기';

  @override
  String get createFamily => '새 가족 그룹 만들기';

  @override
  String get noFamily => '가족 그룹이 없습니다';

  @override
  String get noFamilyHint => '가족을 만들거나 초대 코드로 합류하세요';

  @override
  String get inviteCode => '초대 코드';

  @override
  String get inviteCodeCopied => '초대 코드가 복사되었습니다';

  @override
  String get copy => '복사';

  @override
  String get share => '공유';

  @override
  String get inviteCodeShareHint => '이 코드를 가족에게 공유하여 함께 기록하세요';

  @override
  String get familyMembers => '가족 구성원';

  @override
  String get familyError => '오류가 발생했습니다';

  @override
  String get joinFamily => '초대 코드로 합류하기';

  @override
  String get enterInviteCode => '초대 코드를 입력해주세요';

  @override
  String get relationshipLabel => '아기와의 관계';

  @override
  String get joinButton => '가족 합류하기';

  @override
  String get enterInviteCodeError => '초대 코드를 입력해주세요';

  @override
  String get selectRelationshipError => '아기와의 관계를 선택해주세요';

  @override
  String get me => '나';

  @override
  String get userLabel => '사용자';

  @override
  String get caregiverRole => '양육자';

  @override
  String get familyRole => '가족';

  @override
  String get familyLoadFailed => '불러오기 실패';

  @override
  String familyShareMessage(String familyName, String code) {
    return 'BebeTap 앱에서 $familyName에 합류하세요!\n초대 코드: $code';
  }

  @override
  String get familyShareSubject => 'BebeTap 가족 초대';

  @override
  String get statistics => '통계';

  @override
  String get sleepSection => '수면';

  @override
  String get totalSleep => '총 수면';

  @override
  String get feedingSection => '수유';

  @override
  String get noFeedingRecord => '기록 없음';

  @override
  String get diaperSection => '기저귀';

  @override
  String get diaperChangeLabel => '기저귀 교체';

  @override
  String timesCount(int count) {
    return '$count회';
  }

  @override
  String diaryCountUnit(int count) {
    return '$count편';
  }

  @override
  String get dataLoadFailed => '데이터를 불러올 수 없습니다';

  @override
  String get periodDay => '오늘';

  @override
  String get periodWeek => '주간';

  @override
  String get periodMonth => '월간';

  @override
  String get logTitle => '육아 기록';

  @override
  String get logLoadFailed => '기록을 불러오지 못했어요';

  @override
  String get noLogForDay => '이 날은 기록이 없어요';

  @override
  String get addLogHint => '+ 버튼을 눌러 기록을 추가해보세요';

  @override
  String get editFormula => '분유 수정';

  @override
  String get editPumped => '유축 수정';

  @override
  String get editBabyFood => '이유식 수정';

  @override
  String get editBreast => '모유 수정';

  @override
  String get editDiaper => '기저귀 수정';

  @override
  String get editSleep => '수면 수정';

  @override
  String get editTemperature => '체온 수정';

  @override
  String get diaryLog => '일기';

  @override
  String get addFormula => '분유 수유';

  @override
  String get addPumped => '유축 수유';

  @override
  String get addBabyFood => '이유식 기록';

  @override
  String get addBreast => '모유 수유';

  @override
  String get addDiaper => '기저귀';

  @override
  String get addSleep => '수면';

  @override
  String get addTemperature => '체온 기록';

  @override
  String get editDiary => '일기 수정';

  @override
  String get writeDiary => '일기 쓰기';

  @override
  String get entryFormula => '분유';

  @override
  String get entryBreast => '모유';

  @override
  String get entryPumped => '유축';

  @override
  String get entryBabyFood => '이유식';

  @override
  String get entrySleep => '수면';

  @override
  String get entrySleeping => '자는 중';

  @override
  String get entryDiaper => '기저귀';

  @override
  String get entryTemperature => '체온';

  @override
  String durationSeconds(int s) {
    return '$s초';
  }

  @override
  String durationMinutesOnly(int m) {
    return '$m분';
  }

  @override
  String durationHoursOnly(int h) {
    return '$h시간';
  }

  @override
  String durationHoursMinutes(int h, int m) {
    return '$h시간 $m분';
  }

  @override
  String get elapsedJustNow => '방금';

  @override
  String elapsedMinutes(int m) {
    return '$m분 경과';
  }

  @override
  String elapsedHoursOnly(int h) {
    return '$h시간 경과';
  }

  @override
  String elapsedHoursMinutes(int h, int m) {
    return '$h시간 $m분 경과';
  }

  @override
  String get settings => '설정';

  @override
  String get iconSettingsTitle => '아이콘 설정';

  @override
  String get iconSettingsHint => '드래그로 순서를 변경하고, 스위치로 표시 여부를 설정하세요.';

  @override
  String get logout => '로그아웃';

  @override
  String get pickerToday => '오늘';

  @override
  String get pickerHour => '시';

  @override
  String get pickerMinute => '분';

  @override
  String get pickerConfirm => '확인';

  @override
  String displayTime(int h, String minute, String period) {
    return '$period $h:$minute';
  }

  @override
  String dateFormatLong(int year, int month, int day, String weekday) {
    return '$year년 $month월 $day일 ($weekday)';
  }
}
