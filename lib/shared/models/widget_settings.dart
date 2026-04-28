import 'dart:convert';

enum WidgetThemeMode { system, light, dark }

enum WidgetButtonKey {
  formula,
  breast,
  pumped,
  babyFood,
  sleep,
  diaper,
  temperature,
  diary;

  String get deeplinkPath => switch (this) {
        WidgetButtonKey.babyFood => 'baby_food',
        _ => name,
      };
}

class WidgetSettings {
  const WidgetSettings({
    this.themeMode = WidgetThemeMode.system,
    this.opacity = 1.0,
    this.selectedButtons = const [
      WidgetButtonKey.formula,
      WidgetButtonKey.breast,
      WidgetButtonKey.pumped,
      WidgetButtonKey.sleep,
      WidgetButtonKey.diaper,
    ],
  });

  static const int maxSelected = 5;

  final WidgetThemeMode themeMode;
  final double opacity;
  final List<WidgetButtonKey> selectedButtons;

  static WidgetSettings defaultSettings() => const WidgetSettings();

  static const List<WidgetButtonKey> catalogOrder = [
    WidgetButtonKey.formula,
    WidgetButtonKey.breast,
    WidgetButtonKey.pumped,
    WidgetButtonKey.babyFood,
    WidgetButtonKey.sleep,
    WidgetButtonKey.diaper,
    WidgetButtonKey.temperature,
    WidgetButtonKey.diary,
  ];

  bool isSelected(WidgetButtonKey key) => selectedButtons.contains(key);

  List<WidgetButtonKey> get unselectedButtons =>
      catalogOrder.where((k) => !selectedButtons.contains(k)).toList();

  /// Returns updated settings, or this if already at max and [key] is not selected.
  WidgetSettings withToggled(WidgetButtonKey key) {
    if (selectedButtons.contains(key)) {
      return copyWith(
        selectedButtons: selectedButtons.where((e) => e != key).toList(),
      );
    }
    if (selectedButtons.length >= maxSelected) return this;
    return copyWith(selectedButtons: [...selectedButtons, key]);
  }

  WidgetSettings withReordered(int oldIndex, int newIndex) {
    final list = List<WidgetButtonKey>.from(selectedButtons);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    return copyWith(selectedButtons: list);
  }

  WidgetSettings copyWith({
    WidgetThemeMode? themeMode,
    double? opacity,
    List<WidgetButtonKey>? selectedButtons,
  }) =>
      WidgetSettings(
        themeMode: themeMode ?? this.themeMode,
        opacity: opacity ?? this.opacity,
        selectedButtons: selectedButtons ?? this.selectedButtons,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'opacity': opacity,
        'selectedButtons': selectedButtons.map((e) => e.name).toList(),
      };

  String toJsonString() => jsonEncode(toJson());

  static WidgetSettings fromJson(Map<String, dynamic> json) {
    try {
      final themeMode = WidgetThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => WidgetThemeMode.system,
      );
      final opacity = ((json['opacity'] as num?) ?? 1.0).toDouble().clamp(0.0, 1.0);
      final buttonNames = (json['selectedButtons'] as List?)?.cast<String>() ?? [];
      final selectedButtons = buttonNames
          .map((name) {
            try {
              return WidgetButtonKey.values.firstWhere((e) => e.name == name);
            } catch (_) {
              return null;
            }
          })
          .whereType<WidgetButtonKey>()
          .take(maxSelected)
          .toList();
      return WidgetSettings(
        themeMode: themeMode,
        opacity: opacity,
        selectedButtons: selectedButtons.isEmpty
            ? defaultSettings().selectedButtons
            : selectedButtons,
      );
    } catch (_) {
      return defaultSettings();
    }
  }

  static WidgetSettings fromJsonString(String json) {
    try {
      return fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return defaultSettings();
    }
  }
}
