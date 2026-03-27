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
  String get formula => '분유';

  @override
  String get breast => '모유';

  @override
  String get diaper => '기저귀';

  @override
  String get sleep => '수면';

  @override
  String get temperature => '체온';

  @override
  String get growth => '성장';

  @override
  String get tapToRecord => '탭해서 기록';

  @override
  String get today => '오늘';

  @override
  String get statistics => '통계';

  @override
  String get family => '가족 공유';

  @override
  String get settings => '설정';

  @override
  String get sleepActive => '수면 중';

  @override
  String get lastFeeding => '마지막 수유';

  @override
  String get formulaTotal => '분유 총량';

  @override
  String get noRecord => '아직 기록이 없어요';

  @override
  String get createFamily => '새 가족 그룹 만들기';

  @override
  String get joinFamily => '초대 코드로 합류하기';

  @override
  String get inviteCode => '초대 코드';
}
