enum AppThemeMode { light, dark, system, scheduled }

class ThemeModeSetting {
  const ThemeModeSetting({
    this.mode = AppThemeMode.system,
    this.darkStartHour = 20,
    this.darkStartMinute = 0,
    this.darkEndHour = 7,
    this.darkEndMinute = 0,
  });

  final AppThemeMode mode;
  final int darkStartHour;
  final int darkStartMinute;
  final int darkEndHour;
  final int darkEndMinute;

  ThemeModeSetting copyWith({
    AppThemeMode? mode,
    int? darkStartHour,
    int? darkStartMinute,
    int? darkEndHour,
    int? darkEndMinute,
  }) {
    return ThemeModeSetting(
      mode: mode ?? this.mode,
      darkStartHour: darkStartHour ?? this.darkStartHour,
      darkStartMinute: darkStartMinute ?? this.darkStartMinute,
      darkEndHour: darkEndHour ?? this.darkEndHour,
      darkEndMinute: darkEndMinute ?? this.darkEndMinute,
    );
  }
}
