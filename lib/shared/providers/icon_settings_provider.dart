import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/log/domain/models/timeline_entry.dart';
import '../../shared/models/icon_settings.dart';
import '../../shared/models/tracking_category.dart';

const _kPrefsKey = 'icon_settings_v1';

final iconSettingsProvider =
    AsyncNotifierProvider<IconSettingsNotifier, IconSettings>(
  IconSettingsNotifier.new,
);

class IconSettingsNotifier extends AsyncNotifier<IconSettings> {
  @override
  Future<IconSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_kPrefsKey);
    if (json == null) return IconSettings.defaultSettings();
    return IconSettings.fromJsonString(json);
  }

  Future<void> toggleVisibility(TimelineEntryType type) async {
    final current = state.valueOrNull ?? IconSettings.defaultSettings();
    final updated = current.withToggled(type);
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.valueOrNull ?? IconSettings.defaultSettings();
    final updated = current.withReordered(oldIndex, newIndex);
    state = AsyncData(updated);
    await _save(updated);
  }

  Future<void> _save(IconSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kPrefsKey, settings.toJsonString());
  }
}

/// Ordered list of visible categories. Falls back to default while loading.
final visibleCategoriesProvider = Provider<List<TimelineEntryType>>((ref) {
  final settings = ref.watch(iconSettingsProvider).valueOrNull;
  return settings?.visibleOrdered ?? TrackingCategoryInfo.defaultOrder;
});

/// All categories in user-defined order (including hidden ones).
/// Used by the settings screen.
final allCategoriesOrderedProvider = Provider<List<CategorySetting>>((ref) {
  final settings = ref.watch(iconSettingsProvider).valueOrNull;
  return settings?.categories ?? IconSettings.defaultSettings().categories;
});
