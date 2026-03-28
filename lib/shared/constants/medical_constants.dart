class MedicalConstants {
  // 분유 수유
  static double formulaDailyTargetMl(double weightKg) => weightKg * 150;
  static const int formulaPickerMinMl = 10;
  static const int formulaPickerMaxMl = 300;
  static const int formulaPickerStepMl = 10;
  static const int formulaDefaultMl = 120;

  // 수유 간격 경고 (시간)
  static const int feedingWarningHours = 3;
  static const int feedingAlertHours = 4;

  // 수면 목표 (시간/일)
  static const double newbornSleepTargetHours = 16.5; // 0-3개월
  static const double threeMonthSleepTargetHours = 15.0; // 3-6개월
  static const double sixMonthSleepTargetHours = 14.0; // 6-12개월

  // 이유식
  static const int babyFoodPickerMinMl = 10;
  static const int babyFoodPickerMaxMl = 300;
  static const int babyFoodPickerStepMl = 10;
  static const int babyFoodDefaultMl = 80;

  // 기저귀
  static const int diaperChangeIntervalHours = 2;

  // 체온 기준 (℃)
  static const double feverThreshold = 37.5;
  static const double highFeverThreshold = 38.5;
}
