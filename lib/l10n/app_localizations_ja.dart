// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'BebeTap';

  @override
  String get tabHome => 'ホーム';

  @override
  String get tabStatistics => '統計';

  @override
  String get tabLog => '記録';

  @override
  String get tabFamily => '家族';

  @override
  String get menuBabyManage => '赤ちゃん管理';

  @override
  String get menuWidgetAdd => 'ウィジェット追加';

  @override
  String get menuIconSettings => 'アイコン設定';

  @override
  String get menuTheme => 'テーマ設定';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get themeSystem => 'システム';

  @override
  String get themeScheduled => 'スケジュール';

  @override
  String get themeScheduleStart => '開始';

  @override
  String get themeScheduleEnd => '終了';

  @override
  String get menuLanguage => '言語設定';

  @override
  String get menuLogout => 'ログアウト';

  @override
  String get logoutConfirmTitle => 'ログアウト';

  @override
  String get logoutConfirmMessage => 'ログアウトしますか？';

  @override
  String get cancel => 'キャンセル';

  @override
  String get comingSoon => '準備中です';

  @override
  String homeGreeting(String name) {
    return 'こんにちは、$name！';
  }

  @override
  String get sectionRecord => '記録する';

  @override
  String get formula => 'ミルク';

  @override
  String get breast => '母乳';

  @override
  String get pumped => '搾乳';

  @override
  String get babyFood => '離乳食';

  @override
  String get diaper => 'おむつ';

  @override
  String get sleep => '睡眠';

  @override
  String get temperature => '体温';

  @override
  String get growth => '成長';

  @override
  String get diary => '日記';

  @override
  String get statsFormulaLabel => 'ミルク';

  @override
  String get statsSleepLabel => '睡眠';

  @override
  String get statsDiaperLabel => 'おむつ';

  @override
  String get tapToRecord => 'タップして記録';

  @override
  String get formulaBottomSheetTitle => 'ミルク授乳';

  @override
  String get breastBottomSheetTitle => '母乳授乳';

  @override
  String get pumpedBottomSheetTitle => '搾乳授乳';

  @override
  String get babyFoodBottomSheetTitle => '離乳食記録';

  @override
  String get temperatureRecordTitle => '体温記録';

  @override
  String get diaryWriteTitle => '日記を書く';

  @override
  String get diaryEditTitle => '日記を修正';

  @override
  String get diaryDoneToday => '今日完成';

  @override
  String get sleepActive => '眠り中';

  @override
  String get lastFeeding => '最後の授乳';

  @override
  String get formulaTotal => 'ミルク合計';

  @override
  String get noRecord => 'まだ記録がありません';

  @override
  String get startRecordingHint => '授乳タイルをタップして開始';

  @override
  String get typeBreastFeeding => '母乳授乳';

  @override
  String get typePumpedFeeding => '搾乳授乳';

  @override
  String get typeBabyFood => '離乳食';

  @override
  String get typeFormulaFeeding => 'ミルク授乳';

  @override
  String get today => '今日';

  @override
  String get yesterday => '昨日';

  @override
  String get am => '午前';

  @override
  String get pm => '午後';

  @override
  String get weekdayMon => '月';

  @override
  String get weekdayTue => '火';

  @override
  String get weekdayWed => '水';

  @override
  String get weekdayThu => '木';

  @override
  String get weekdayFri => '金';

  @override
  String get weekdaySat => '土';

  @override
  String get weekdaySun => '日';

  @override
  String dateFormatMonthDay(int month, int day) {
    return '$month月$day日';
  }

  @override
  String dateFormatFull(int month, int day, String weekday) {
    return '$month月$day日($weekday)';
  }

  @override
  String dateFormatTodayNav(int month, int day, String weekday) {
    return '$month月$day日($weekday)  今日';
  }

  @override
  String get save => '保存';

  @override
  String get edit => '修正';

  @override
  String get delete => '削除';

  @override
  String get deleteConfirmTitle => '記録を削除';

  @override
  String get deleteConfirmMessage => 'この記録を削除しますか？';

  @override
  String get confirm => '確認';

  @override
  String saveAmountMl(String amount) {
    return '$amountを保存';
  }

  @override
  String editAmountMl(String amount) {
    return '$amountを修正';
  }

  @override
  String formulaRecommendation(String weight, int ml) {
    return '${weight}kg基準 推奨量 ${ml}ml/日';
  }

  @override
  String get formulaWeightHint => '体重を入力すると推奨量が確認できます';

  @override
  String todayAmount(String amount) {
    return '今日 $amount';
  }

  @override
  String get menuVolumeUnit => '単位設定';

  @override
  String get volumeUnitMl => 'ミリリットル (ml)';

  @override
  String get volumeUnitOz => 'オンス (oz)';

  @override
  String todayCount(int count) {
    return '今日 $count回';
  }

  @override
  String todayDuration(String duration) {
    return '今日 $duration';
  }

  @override
  String get left => '左';

  @override
  String get right => '右';

  @override
  String minuteUnit(int min) {
    return '$min分';
  }

  @override
  String get diaperSelectType => 'おむつの種類を選んでください';

  @override
  String get diaperWet => 'おしっこ';

  @override
  String get diaperSoiled => 'うんち';

  @override
  String get diaperBoth => '両方';

  @override
  String get diaperChange => '交換';

  @override
  String get sleepEdit => '睡眠を修正';

  @override
  String get sleepRecord => '睡眠記録';

  @override
  String get sleepStart => '睡眠開始';

  @override
  String get sleepEnd => '睡眠終了';

  @override
  String get sleepHint => '睡眠を開始するとタイマーが動作します。\nアプリを終了しても記録は保持されます。';

  @override
  String get sleepEndTimeError => '終了時刻は開始時刻より前にできません';

  @override
  String get startTime => '開始';

  @override
  String get endTime => '終了';

  @override
  String startHourMinute(int hour, String minute) {
    return '$hour時$minute分';
  }

  @override
  String get measureMethod => '測定方法';

  @override
  String get methodAxillary => '脇';

  @override
  String get methodEar => '耳';

  @override
  String get methodForehead => '額';

  @override
  String get methodRectal => '肛門';

  @override
  String get highFeverWarning => '高熱です。すぐに医師に相談してください。';

  @override
  String get lowFeverWarning => '微熱です。経過を注意深く観察してください。';

  @override
  String get diaryTitleHint => 'タイトルを入力してください';

  @override
  String get diaryContentHint => '今日の赤ちゃんとの出来事を書いてください...';

  @override
  String get diaryAuthorLabel => '作成者';

  @override
  String get diaryReadOnly => '他の作成者の日記は修正できません。';

  @override
  String get loginSubtitle => '新米パパ・ママのための育児記録アプリ';

  @override
  String get email => 'メール';

  @override
  String get password => 'パスワード';

  @override
  String get forgotPassword => 'パスワードをお忘れですか？';

  @override
  String get signupWithEmail => 'メールで会員登録';

  @override
  String get login => 'ログイン';

  @override
  String get orSocialLogin => 'またはソーシャルログイン';

  @override
  String get continueWithGoogle => 'Googleで続ける';

  @override
  String get continueWithKakao => 'カカオで続ける';

  @override
  String get continueWithFacebook => 'Facebookで続ける';

  @override
  String get continueWithLine => 'Lineで続ける';

  @override
  String get invalidEmailPassword => 'メールまたはパスワードが正しくありません';

  @override
  String get networkError => 'ネットワークエラーが発生しました。再試行してください。';

  @override
  String loginFailed(String error) {
    return 'ログイン失敗: $error';
  }

  @override
  String get passwordReset => 'パスワード再設定';

  @override
  String get emailAddressLabel => 'メールアドレス';

  @override
  String get send => '送信';

  @override
  String get resetEmailSent => 'パスワード再設定メールを送信しました。';

  @override
  String sendFailed(String error) {
    return '送信失敗: $error';
  }

  @override
  String get emailSignupTitle => 'メール会員登録';

  @override
  String get enterEmailPrompt => '登録するメールアドレスを入力してください';

  @override
  String get sendVerification => '認証メールを送信';

  @override
  String get alreadyHaveAccount => 'すでにアカウントをお持ちですか？ログイン';

  @override
  String get setPasswordTitle => 'パスワードを設定してください';

  @override
  String get setPasswordHint => '次回のログインからメールとパスワードでログインします';

  @override
  String get passwordInput => 'パスワード（6文字以上）';

  @override
  String get passwordConfirm => 'パスワード確認';

  @override
  String get enterOtpTitle => '認証コードを入力してください';

  @override
  String get enterOtpHint => 'メールに送信された6桁のコードを入力してください';

  @override
  String get completeSignup => '登録完了';

  @override
  String get resendEmail => 'メールを再送信';

  @override
  String get invalidEmail => '正しいメール形式を入力してください';

  @override
  String get emailAlreadyExists => '既に登録済みのメールです。ログインページへ移動します。';

  @override
  String sendOtpFailed(String error) {
    return '送信失敗: $error';
  }

  @override
  String get passwordTooShort => 'パスワードは6文字以上にしてください';

  @override
  String get passwordMismatch => 'パスワードが一致しません';

  @override
  String get enterSixDigitCode => '6桁の認証コードを入力してください';

  @override
  String signupFailed(String error) {
    return '登録失敗: $error';
  }

  @override
  String get resendSuccess => '認証コードを再送信しました。';

  @override
  String resendFailed(String error) {
    return '再送信失敗: $error';
  }

  @override
  String get next => '次へ';

  @override
  String get babyManageTitle => '赤ちゃん管理';

  @override
  String get registeredBabies => '登録された赤ちゃん';

  @override
  String get addNewBaby => '新しい赤ちゃんを追加';

  @override
  String get babyName => '赤ちゃんの名前 *';

  @override
  String get birthDate => '生年月日 *';

  @override
  String get genderOptional => '性別（任意）';

  @override
  String get boy => '男の子';

  @override
  String get girl => '女の子';

  @override
  String get currentWeight => '現在の体重 kg（任意）';

  @override
  String get photoSelect => '写真を選択（任意）';

  @override
  String get selectBirthDate => '日付を選択してください';

  @override
  String get birthDatePrompt => '生年月日を選択してください';

  @override
  String get babyNameHint => '例: たろう';

  @override
  String get babyNameRequired => '名前を入力してください';

  @override
  String get invalidWeight => '正しい体重を入力してください（0~30 kg）';

  @override
  String get weightHint => '例: 4.5';

  @override
  String get weightFormulaHint => '体重を入力するとミルクの1日推奨量が計算されます';

  @override
  String get babyRelationship => '赤ちゃんとの関係 *';

  @override
  String get or => 'または';

  @override
  String get joinWithInviteCode => '招待コードで参加する';

  @override
  String get selectBaby => 'お子さまを選択';

  @override
  String get babySetupTitle => '赤ちゃん情報入力';

  @override
  String get babyEditTitle => '赤ちゃんを修正';

  @override
  String get babyAddTitle => '赤ちゃんを追加';

  @override
  String get addButton => '追加する';

  @override
  String get editButton => '修正する';

  @override
  String get noFamilyFound => '家族情報が見つかりません';

  @override
  String saveFailed(String error) {
    return '保存失敗: $error';
  }

  @override
  String loadFailed(String error) {
    return '読み込み失敗: $error';
  }

  @override
  String get babyRelationshipPrompt => '赤ちゃんとの関係を選択してください';

  @override
  String get startButton => '開始する';

  @override
  String get dateFormat => 'yyyy年MM月dd日';

  @override
  String get relationMom => 'ママ';

  @override
  String get relationDad => 'パパ';

  @override
  String get relationGrandma => 'おばあちゃん';

  @override
  String get relationGrandpa => 'おじいちゃん';

  @override
  String get relationAunt => '叔母';

  @override
  String get relationUncle => '叔父';

  @override
  String get relationPaternalAunt => '叔母（父方）';

  @override
  String get relationMaternalUncle => '叔父（母方）';

  @override
  String get relationCustom => '直接入力';

  @override
  String get relationCustomHint => '例: 祖母、叔母';

  @override
  String get familyTitle => '家族共有';

  @override
  String get familyGroupName => '家族名';

  @override
  String get familyNameHint => '例: 田中家';

  @override
  String get createFamilyDialog => '家族グループを作成';

  @override
  String get makeFamily => '作成';

  @override
  String get createFamily => '新しい家族グループを作成';

  @override
  String get noFamily => '家族グループがありません';

  @override
  String get noFamilyHint => '家族を作るか、招待コードで参加してください';

  @override
  String get inviteCode => '招待コード';

  @override
  String get inviteCodeCopied => '招待コードをコピーしました';

  @override
  String get copy => 'コピー';

  @override
  String get share => '共有';

  @override
  String get inviteCodeShareHint => 'このコードを家族に共有して一緒に記録してください';

  @override
  String get familyMembers => '家族メンバー';

  @override
  String get familyError => 'エラーが発生しました';

  @override
  String get joinFamily => '招待コードで参加する';

  @override
  String get enterInviteCode => '招待コードを入力してください';

  @override
  String get relationshipLabel => '赤ちゃんとの関係';

  @override
  String get joinButton => '家族に参加する';

  @override
  String get enterInviteCodeError => '招待コードを入力してください';

  @override
  String get selectRelationshipError => '赤ちゃんとの関係を選択してください';

  @override
  String get me => '私';

  @override
  String get userLabel => 'ユーザー';

  @override
  String get caregiverRole => '養育者';

  @override
  String get familyRole => '家族';

  @override
  String get familyLoadFailed => '読み込み失敗';

  @override
  String familyShareMessage(String familyName, String code) {
    return 'BebeTapアプリで$familyNameに参加しましょう！\n招待コード: $code';
  }

  @override
  String get familyShareSubject => 'BebeTap 家族招待';

  @override
  String get statistics => '統計';

  @override
  String get sleepSection => '睡眠';

  @override
  String get totalSleep => '合計睡眠';

  @override
  String get feedingSection => '授乳';

  @override
  String get noFeedingRecord => '記録なし';

  @override
  String get diaperSection => 'おむつ';

  @override
  String get diaperChangeLabel => 'おむつ交換';

  @override
  String timesCount(int count) {
    return '$count回';
  }

  @override
  String diaryCountUnit(int count) {
    return '$count件';
  }

  @override
  String get dataLoadFailed => 'データを読み込めません';

  @override
  String get periodDay => '今日';

  @override
  String get periodWeek => '週間';

  @override
  String get periodMonth => '月間';

  @override
  String get period3Months => '3ヶ月';

  @override
  String get period6Months => '6ヶ月';

  @override
  String get insightsTitle => 'インサイト';

  @override
  String get lifePattern => '生活パターン';

  @override
  String get lifePatternTip => '💡 アイコンをタップすると、見たい項目だけ絞り込めます';

  @override
  String get feedingStatsTitle => '授乳統計';

  @override
  String get babyFoodStatsTitle => '離乳食統計';

  @override
  String get sleepStatsTitle => '睡眠統計';

  @override
  String get viewDetails => '詳しく見る';

  @override
  String get totalBabyFood => '離乳食合計';

  @override
  String get babyFoodCount => '離乳食回数';

  @override
  String get noBabyFoodRecord => '離乳食の記録なし';

  @override
  String get dailyBabyFoodTrend => '離乳食の日別推移';

  @override
  String get logTitle => '育児記録';

  @override
  String get logLoadFailed => '記録を読み込めませんでした';

  @override
  String get noLogForDay => 'この日の記録がありません';

  @override
  String get addLogHint => '＋ボタンをタップして記録を追加してください';

  @override
  String get editFormula => 'ミルクを修正';

  @override
  String get editPumped => '搾乳を修正';

  @override
  String get editBabyFood => '離乳食を修正';

  @override
  String get editBreast => '母乳を修正';

  @override
  String get editDiaper => 'おむつを修正';

  @override
  String get editSleep => '睡眠を修正';

  @override
  String get editTemperature => '体温を修正';

  @override
  String get diaryLog => '日記';

  @override
  String get addFormula => 'ミルク授乳';

  @override
  String get addPumped => '搾乳';

  @override
  String get addBabyFood => '離乳食';

  @override
  String get addBreast => '母乳授乳';

  @override
  String get addDiaper => 'おむつ';

  @override
  String get addSleep => '睡眠';

  @override
  String get addTemperature => '体温記録';

  @override
  String get editDiary => '日記を修正';

  @override
  String get writeDiary => '日記を書く';

  @override
  String get entryFormula => 'ミルク';

  @override
  String get entryBreast => '母乳';

  @override
  String get entryPumped => '搾乳';

  @override
  String get entryBabyFood => '離乳食';

  @override
  String get entrySleep => '睡眠';

  @override
  String get entrySleeping => '眠り中';

  @override
  String get entryDiaper => 'おむつ';

  @override
  String get entryTemperature => '体温';

  @override
  String durationSeconds(int s) {
    return '$s秒';
  }

  @override
  String durationMinutesOnly(int m) {
    return '$m分';
  }

  @override
  String durationHoursOnly(int h) {
    return '$h時間';
  }

  @override
  String durationHoursMinutes(int h, int m) {
    return '$h時間$m分';
  }

  @override
  String get elapsedJustNow => 'たった今';

  @override
  String elapsedMinutes(int m) {
    return '$m分経過';
  }

  @override
  String elapsedHoursOnly(int h) {
    return '$h時間経過';
  }

  @override
  String elapsedHoursMinutes(int h, int m) {
    return '$h時間$m分経過';
  }

  @override
  String get settings => '設定';

  @override
  String get iconSettingsTitle => 'アイコン設定';

  @override
  String get iconSettingsHint => 'ドラッグで順序を変更し、スイッチで表示/非表示を設定してください。';

  @override
  String get logout => 'ログアウト';

  @override
  String get pickerToday => '今日';

  @override
  String get pickerHour => '時';

  @override
  String get pickerMinute => '分';

  @override
  String get pickerConfirm => '確認';

  @override
  String displayTime(int h, String minute, String period) {
    return '$period$h:$minute';
  }

  @override
  String dateFormatLong(int year, int month, int day, String weekday) {
    return '$year年$month月$day日（$weekday）';
  }

  @override
  String get napSleep => '昼寝';

  @override
  String get nightSleep => '夜睡眠';

  @override
  String get napVsNight => '昼寝 vs 夜睡眠';

  @override
  String get dailySleepTrend => '日別睡眠推移';

  @override
  String get longestSleep => '最長連続睡眠';

  @override
  String get bedtimeConsistency => '就寝時刻の一貫性';

  @override
  String get avgDailySleep => '1日平均睡眠';

  @override
  String get belowRecommended => '推奨以下';

  @override
  String get aboveRecommended => '推奨超過';

  @override
  String get withinRecommended => '適正範囲';

  @override
  String get recommended => '推奨';

  @override
  String get avgFeedingInterval => '平均授乳間隔';

  @override
  String get dailyIntakeTrend => '日別摂取量推移';

  @override
  String get leftRightBalance => '左右バランス';

  @override
  String get leftBreast => '左';

  @override
  String get rightBreast => '右';

  @override
  String get wetDiaper => 'おしっこ';

  @override
  String get soiledDiaper => 'うんち';

  @override
  String get bothDiaper => '両方';

  @override
  String get dailyDiaperTrend => '日別おむつ推移';

  @override
  String get healthSection => '健康';

  @override
  String get avgLabel => '平均';

  @override
  String get temperatureTrend => '体温推移';

  @override
  String get dailyRoutine => '生活リズム';

  @override
  String get heatmapLow => '少';

  @override
  String get heatmapHigh => '多';

  @override
  String get insightsSection => 'インサイト';

  @override
  String insightFeedingPredictionBody(String minutes) {
    return '約$minutes分後にお腹が空くかもしれません';
  }

  @override
  String insightNapPredictionBody(String minutes) {
    return 'パターンから、約$minutes分後がお昼寝の時間です';
  }

  @override
  String insightIntakeDropBody(String percent) {
    return '過去3日間でミルク摂取量が$percent%減少しました';
  }

  @override
  String insightLowWetDiapersBody(String count) {
    return '24時間以内のおしっこおむつが$count回のみです — 水分摂取を確認してください';
  }

  @override
  String insightFeverBody(String temp) {
    return '最新体温$temp°Cが正常範囲を超えています';
  }

  @override
  String insightSleepRegressionBody(String percent) {
    return '先週と比べて総睡眠が$percent%減少しました';
  }

  @override
  String get insightNapNightCorrelationBody => '昼寝が少ない日は夜に起きる回数が多い傾向があります';

  @override
  String get babyComparison => '比較';

  @override
  String get comparisonAge => '比較する日齢';

  @override
  String get daysLabel => '日';

  @override
  String get monthsLabel => 'ヶ月';

  @override
  String get comparisonNeedTwoBabies => '比較するには2人以上の赤ちゃんを登録してください';

  @override
  String babyAgeDays(int count) {
    return '$count日';
  }

  @override
  String babyAgeMonths(int months) {
    return '$monthsヶ月';
  }

  @override
  String babyAgeMonthsDays(int months, int days) {
    return '$monthsヶ月$days日';
  }

  @override
  String get currentHeight => '現在の身長';

  @override
  String get heightHint => '例: 65.5';

  @override
  String get invalidHeight => '有効な身長を入力してください（1〜150 cm）';

  @override
  String get growthStatsTitle => '身長・体重';

  @override
  String get growthStatsEmpty => '赤ちゃん管理画面で身長・体重を登録すると\n平均と比較できます';

  @override
  String growthPercentileLabel(int p) {
    return '$pパーセンタイル';
  }

  @override
  String growthAboveAverage(String diff) {
    return '平均より +$diff';
  }

  @override
  String growthBelowAverage(String diff) {
    return '平均より -$diff';
  }

  @override
  String get growthOnAverage => '平均付近';

  @override
  String get growthHeightLabel => '身長';

  @override
  String get growthWeightLabel => '体重';

  @override
  String get growthWhoReference => 'WHO 成長基準準拠';

  @override
  String growthCurrentAge(int months) {
    return '月齢: $monthsヶ月';
  }

  @override
  String get growthNoData => 'データなし';

  @override
  String get growthGoToManage => '赤ちゃん情報を入力';
}
