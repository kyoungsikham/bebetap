import 'package:flutter/material.dart';
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

/// 오늘의 한 마디 색상 — 날짜 기반으로 따뜻한 팔레트에서 순환.
/// 같은 날은 항상 같은 색상, 날짜가 바뀌면 다음 색상으로 변경.
const _warmColorsLight = [
  Color(0xFFC47A65), // 테라코타
  Color(0xFFC98B4A), // 황토 앰버
  Color(0xFFBF6878), // 로즈
  Color(0xFFBB8040), // 카라멜
  Color(0xFFA87060), // 더스티 코퍼
  Color(0xFFB87878), // 더스티 로즈
  Color(0xFFB8935A), // 웜 오커
];

const _warmColorsDark = [
  Color(0xFFE8AA80), // 피치
  Color(0xFFE8C080), // 골든 허니
  Color(0xFFE89080), // 코랄
  Color(0xFFE8A0A8), // 로즈 골드
  Color(0xFFDDB870), // 앰버
  Color(0xFFE89878), // 살몬
  Color(0xFFE8C878), // 소프트 허니
];

final dailyMessageColorProvider = Provider.family<Color, Brightness>((ref, brightness) {
  final daysSinceEpoch =
      DateTime.now().toUtc().millisecondsSinceEpoch ~/
      Duration.millisecondsPerDay;
  final palette = brightness == Brightness.dark ? _warmColorsDark : _warmColorsLight;
  return palette[daysSinceEpoch % palette.length];
});
