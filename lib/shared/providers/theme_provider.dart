import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/theme_mode_setting.dart';

const _kThemeModeKey = 'app_theme_mode';
const _kDarkStartKey = 'dark_start_minutes';
const _kDarkEndKey = 'dark_end_minutes';

final themeSettingProvider =
    AsyncNotifierProvider<ThemeSettingNotifier, ThemeModeSetting>(
  ThemeSettingNotifier.new,
);

class ThemeSettingNotifier extends AsyncNotifier<ThemeModeSetting> {
  @override
  Future<ThemeModeSetting> build() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_kThemeModeKey);
    final mode = AppThemeMode.values.firstWhere(
      (e) => e.name == modeStr,
      orElse: () => AppThemeMode.system,
    );
    final startMinutes = prefs.getInt(_kDarkStartKey) ?? (20 * 60);
    final endMinutes = prefs.getInt(_kDarkEndKey) ?? (7 * 60);
    return ThemeModeSetting(
      mode: mode,
      darkStartHour: startMinutes ~/ 60,
      darkStartMinute: startMinutes % 60,
      darkEndHour: endMinutes ~/ 60,
      darkEndMinute: endMinutes % 60,
    );
  }

  Future<void> setMode(AppThemeMode mode) async {
    final current = state.valueOrNull ?? const ThemeModeSetting();
    state = AsyncData(current.copyWith(mode: mode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kThemeModeKey, mode.name);
  }

  Future<void> setSchedule({
    required int startHour,
    required int startMinute,
    required int endHour,
    required int endMinute,
  }) async {
    final current = state.valueOrNull ?? const ThemeModeSetting();
    state = AsyncData(current.copyWith(
      darkStartHour: startHour,
      darkStartMinute: startMinute,
      darkEndHour: endHour,
      darkEndMinute: endMinute,
    ));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kDarkStartKey, startHour * 60 + startMinute);
    await prefs.setInt(_kDarkEndKey, endHour * 60 + endMinute);
  }
}

/// 현재 시각 기준으로 예약 다크 윈도우 내인지 확인 (자정 넘는 경우 처리)
bool _isInDarkWindow(ThemeModeSetting setting) {
  final now = TimeOfDay.now();
  final nowMinutes = now.hour * 60 + now.minute;
  final startMinutes = setting.darkStartHour * 60 + setting.darkStartMinute;
  final endMinutes = setting.darkEndHour * 60 + setting.darkEndMinute;

  if (startMinutes <= endMinutes) {
    // 자정을 넘지 않는 경우 (예: 08:00 ~ 20:00)
    return nowMinutes >= startMinutes && nowMinutes < endMinutes;
  } else {
    // 자정을 넘는 경우 (예: 20:00 ~ 07:00)
    return nowMinutes >= startMinutes || nowMinutes < endMinutes;
  }
}

/// 설정 + 현재 시각을 기반으로 실제 Flutter ThemeMode 반환
final resolvedThemeModeProvider = Provider<ThemeMode>((ref) {
  final setting =
      ref.watch(themeSettingProvider).valueOrNull ?? const ThemeModeSetting();

  switch (setting.mode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
    case AppThemeMode.scheduled:
      return _isInDarkWindow(setting) ? ThemeMode.dark : ThemeMode.light;
  }
});

/// 예약 모드에서 다음 전환 시점에 provider를 재평가하는 타이머
final scheduledThemeRefreshProvider = Provider<void>((ref) {
  final setting = ref.watch(themeSettingProvider).valueOrNull;
  if (setting == null || setting.mode != AppThemeMode.scheduled) return;

  final now = TimeOfDay.now();
  final nowMinutes = now.hour * 60 + now.minute;
  final startMinutes = setting.darkStartHour * 60 + setting.darkStartMinute;
  final endMinutes = setting.darkEndHour * 60 + setting.darkEndMinute;

  // 다음 전환까지 남은 분 계산
  int minutesUntilNext;
  final currentlyDark = _isInDarkWindow(setting);
  if (currentlyDark) {
    // 현재 다크 → 다음 전환은 end
    minutesUntilNext = endMinutes > nowMinutes
        ? endMinutes - nowMinutes
        : (24 * 60 - nowMinutes) + endMinutes;
  } else {
    // 현재 라이트 → 다음 전환은 start
    minutesUntilNext = startMinutes > nowMinutes
        ? startMinutes - nowMinutes
        : (24 * 60 - nowMinutes) + startMinutes;
  }

  final timer = Timer(
    Duration(minutes: minutesUntilNext + 1),
    () => ref.invalidate(resolvedThemeModeProvider),
  );

  ref.onDispose(timer.cancel);
});
