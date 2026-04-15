import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/daily_messages_en.dart';
import '../../data/daily_messages_ja.dart';
import '../../data/daily_messages_ko.dart';
import '../../../../shared/providers/locale_provider.dart';

/// 오늘의 한 마디 — UTC 날짜 기반 결정론적 선택.
/// 같은 날 같은 로캘이면 항상 동일 문구, 자정이 지나면 자동으로 다음 문구.
final dailyMessageProvider = Provider<String>((ref) {
  final locale = ref.watch(localeProvider).valueOrNull?.languageCode ?? 'en';
  final list = switch (locale) {
    'ko' => kDailyMessagesKo,
    'ja' => kDailyMessagesJa,
    _ => kDailyMessagesEn,
  };
  if (list.isEmpty) return '';
  final daysSinceEpoch =
      DateTime.now().toUtc().millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
  return list[daysSinceEpoch % list.length];
});
