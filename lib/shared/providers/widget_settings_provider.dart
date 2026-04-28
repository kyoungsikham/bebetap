import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/widget/widget_sync_service.dart';
import '../models/widget_settings.dart';

const _kPrefsKey = 'widget_settings_v1';

final widgetSettingsProvider =
    AsyncNotifierProvider<WidgetSettingsNotifier, WidgetSettings>(
  WidgetSettingsNotifier.new,
);

class WidgetSettingsNotifier extends AsyncNotifier<WidgetSettings> {
  @override
  Future<WidgetSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kPrefsKey);
    if (json == null) return WidgetSettings.defaultSettings();
    return WidgetSettings.fromJsonString(json);
  }

  Future<void> setThemeMode(WidgetThemeMode mode) async {
    final updated = (state.valueOrNull ?? WidgetSettings.defaultSettings())
        .copyWith(themeMode: mode);
    state = AsyncData(updated);
    await _save(updated);
    await WidgetSyncService.pushSettings(updated);
  }

  Future<void> setOpacity(double opacity) async {
    final updated = (state.valueOrNull ?? WidgetSettings.defaultSettings())
        .copyWith(opacity: opacity.clamp(0.0, 1.0));
    state = AsyncData(updated);
    await _save(updated);
    await WidgetSyncService.pushSettings(updated);
  }

  /// 버튼 on/off 토글. 상한(5개)에서 추가 시도 시 false 반환.
  Future<bool> toggleButton(WidgetButtonKey key) async {
    final current = state.valueOrNull ?? WidgetSettings.defaultSettings();
    if (!current.isSelected(key) &&
        current.selectedButtons.length >= WidgetSettings.maxSelected) {
      return false;
    }
    final updated = current.withToggled(key);
    state = AsyncData(updated);
    await _save(updated);
    await WidgetSyncService.pushSettings(updated);
    return true;
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.valueOrNull ?? WidgetSettings.defaultSettings();
    final updated = current.withReordered(oldIndex, newIndex);
    state = AsyncData(updated);
    await _save(updated);
    await WidgetSyncService.pushSettings(updated);
  }

  Future<void> _save(WidgetSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKey, settings.toJsonString());
  }
}
