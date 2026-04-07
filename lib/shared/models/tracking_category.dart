import 'package:flutter/material.dart';

import '../../features/log/domain/models/timeline_entry.dart';
import '../../l10n/app_localizations.dart';

class TrackingCategoryInfo {
  const TrackingCategoryInfo({
    required this.type,
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
  });

  final TimelineEntryType type;
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  static const List<TimelineEntryType> defaultOrder = [
    TimelineEntryType.formula,
    TimelineEntryType.breast,
    TimelineEntryType.pumped,
    TimelineEntryType.diaper,
    TimelineEntryType.sleep,
    TimelineEntryType.temperature,
    TimelineEntryType.babyFood,
    TimelineEntryType.diary,
  ];

  static const Map<TimelineEntryType, TrackingCategoryInfo> all = {
    TimelineEntryType.formula: TrackingCategoryInfo(
      type: TimelineEntryType.formula,
      icon: Icons.local_drink,
      label: '분유',
      color: Color(0xFF5B7FFF),
      bgColor: Color(0xFFEEF2FF),
    ),
    TimelineEntryType.breast: TrackingCategoryInfo(
      type: TimelineEntryType.breast,
      icon: Icons.favorite_outline,
      label: '모유',
      color: Color(0xFFE91E8C),
      bgColor: Color(0xFFFCE4EC),
    ),
    TimelineEntryType.pumped: TrackingCategoryInfo(
      type: TimelineEntryType.pumped,
      icon: Icons.water_drop_outlined,
      label: '유축수유',
      color: Color(0xFF8E24AA),
      bgColor: Color(0xFFF3E5F5),
    ),
    TimelineEntryType.diaper: TrackingCategoryInfo(
      type: TimelineEntryType.diaper,
      icon: Icons.baby_changing_station,
      label: '기저귀',
      color: Color(0xFF52B788),
      bgColor: Color(0xFFE8F5E9),
    ),
    TimelineEntryType.sleep: TrackingCategoryInfo(
      type: TimelineEntryType.sleep,
      icon: Icons.bedtime,
      label: '수면',
      color: Color(0xFF7B68EE),
      bgColor: Color(0xFFEDE7F6),
    ),
    TimelineEntryType.temperature: TrackingCategoryInfo(
      type: TimelineEntryType.temperature,
      icon: Icons.device_thermostat,
      label: '체온',
      color: Color(0xFFFF7043),
      bgColor: Color(0xFFFBE9E7),
    ),
    TimelineEntryType.babyFood: TrackingCategoryInfo(
      type: TimelineEntryType.babyFood,
      icon: Icons.restaurant,
      label: '이유식',
      color: Color(0xFFFF9800),
      bgColor: Color(0xFFFFF3E0),
    ),
    TimelineEntryType.diary: TrackingCategoryInfo(
      type: TimelineEntryType.diary,
      icon: Icons.auto_stories,
      label: '일기',
      color: Color(0xFF42A5F5),
      bgColor: Color(0xFFE3F2FD),
    ),
  };
}

extension TrackingCategoryInfoL10n on TrackingCategoryInfo {
  String localizedLabel(AppLocalizations l10n) {
    switch (type) {
      case TimelineEntryType.formula:
        return l10n.formula;
      case TimelineEntryType.breast:
        return l10n.breast;
      case TimelineEntryType.pumped:
        return l10n.pumped;
      case TimelineEntryType.diaper:
        return l10n.diaper;
      case TimelineEntryType.sleep:
        return l10n.sleep;
      case TimelineEntryType.temperature:
        return l10n.temperature;
      case TimelineEntryType.babyFood:
        return l10n.babyFood;
      case TimelineEntryType.diary:
        return l10n.diary;
    }
  }
}
