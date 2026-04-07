import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/extensions/datetime_ext.dart';

enum TimelineEntryType { formula, breast, pumped, babyFood, sleep, diaper, temperature, diary }

@immutable
class TimelineEntry {
  const TimelineEntry({
    required this.id,
    required this.type,
    required this.occurredAt,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.rawAmountMl,
    this.rawDurationLeftSec,
    this.rawDurationRightSec,
    this.rawDiaperType,
    this.rawCelsius,
    this.rawMethod,
    this.rawEndedAt,
    this.rawTitle,
    this.rawContent,
    this.rawRecordedBy,
    this.rawAuthorNickname,
  });

  final String id;
  final TimelineEntryType type;
  final DateTime occurredAt;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  // Edit form pre-population
  final int? rawAmountMl;
  final int? rawDurationLeftSec;
  final int? rawDurationRightSec;
  final String? rawDiaperType;
  final double? rawCelsius;
  final String? rawMethod;
  final DateTime? rawEndedAt;
  // Diary fields
  final String? rawTitle;
  final String? rawContent;
  final String? rawRecordedBy;
  final String? rawAuthorNickname;

  factory TimelineEntry.fromFeedingRow(FeedingEntriesTableData row) {
    switch (row.type) {
      case 'breast':
        final leftSec = row.durationLeftSec ?? 0;
        final rightSec = row.durationRightSec ?? 0;
        final dur = Duration(seconds: leftSec + rightSec);
        return TimelineEntry(
          id: row.id,
          type: TimelineEntryType.breast,
          occurredAt: row.startedAt,
          title: '모유',
          subtitle: dur.formatKorean(),
          icon: Icons.favorite_outline,
          color: const Color(0xFFE91E8C),
          rawDurationLeftSec: leftSec,
          rawDurationRightSec: rightSec,
        );
      case 'pumped':
        return TimelineEntry(
          id: row.id,
          type: TimelineEntryType.pumped,
          occurredAt: row.startedAt,
          title: '유축',
          subtitle: '${row.amountMl ?? 0}ml',
          icon: Icons.water_drop_outlined,
          color: const Color(0xFF8E24AA),
          rawAmountMl: row.amountMl,
        );
      case 'baby_food':
        return TimelineEntry(
          id: row.id,
          type: TimelineEntryType.babyFood,
          occurredAt: row.startedAt,
          title: '이유식',
          subtitle: '${row.amountMl ?? 0}ml',
          icon: Icons.restaurant,
          color: const Color(0xFFFF9800),
          rawAmountMl: row.amountMl,
        );
      default: // formula
        return TimelineEntry(
          id: row.id,
          type: TimelineEntryType.formula,
          occurredAt: row.startedAt,
          title: '분유',
          subtitle: '${row.amountMl ?? 0}ml',
          icon: Icons.local_drink,
          color: AppColors.primary,
          rawAmountMl: row.amountMl,
        );
    }
  }

  factory TimelineEntry.fromSleepRow(SleepEntriesTableData row) {
    final start = row.startedAt;
    final end = row.endedAt ?? DateTime.now();
    final dur = end.difference(start);
    final isActive = row.endedAt == null;
    return TimelineEntry(
      id: row.id,
      type: TimelineEntryType.sleep,
      occurredAt: row.startedAt,
      title: '수면',
      subtitle: isActive ? '자는 중' : dur.formatKorean(),
      icon: Icons.bedtime,
      color: const Color(0xFF7B68EE),
      rawEndedAt: row.endedAt,
    );
  }

  factory TimelineEntry.fromDiaperRow(DiaperEntriesTableData row) {
    String typeLabel;
    switch (row.type) {
      case 'wet':
        typeLabel = '소변';
      case 'soiled':
        typeLabel = '대변';
      case 'both':
        typeLabel = '소변+대변';
      case 'dry':
        typeLabel = '교체';
      default:
        typeLabel = row.type;
    }
    return TimelineEntry(
      id: row.id,
      type: TimelineEntryType.diaper,
      occurredAt: row.occurredAt,
      title: '기저귀',
      subtitle: typeLabel,
      icon: Icons.baby_changing_station,
      color: const Color(0xFF52B788),
      rawDiaperType: row.type,
    );
  }

  factory TimelineEntry.fromTemperatureRow(TemperatureEntriesTableData row) {
    return TimelineEntry(
      id: row.id,
      type: TimelineEntryType.temperature,
      occurredAt: row.occurredAt,
      title: '체온',
      subtitle: '${row.celsius.toStringAsFixed(1)}°C',
      icon: Icons.device_thermostat,
      color: const Color(0xFFFF7043),
      rawCelsius: row.celsius,
      rawMethod: row.method,
    );
  }

  factory TimelineEntry.fromDiaryRow(DiaryEntriesTableData row) {
    return TimelineEntry(
      id: row.id,
      type: TimelineEntryType.diary,
      occurredAt: row.entryDate,
      title: row.title,
      subtitle: row.authorNickname ?? '작성자',
      icon: Icons.auto_stories,
      color: const Color(0xFF42A5F5),
      rawTitle: row.title,
      rawContent: row.content,
      rawRecordedBy: row.recordedBy,
      rawAuthorNickname: row.authorNickname,
    );
  }
}

@immutable
class LogDaySummary {
  const LogDaySummary({
    required this.formulaTotalMl,
    required this.breastTotalSec,
    required this.pumpedTotalMl,
    required this.babyFoodTotalMl,
    required this.diaperCount,
    required this.sleepTotal,
    required this.temperatureCount,
    required this.diaryCount,
  });

  final int formulaTotalMl;
  final int breastTotalSec;
  final int pumpedTotalMl;
  final int babyFoodTotalMl;
  final int diaperCount;
  final Duration sleepTotal;
  final int temperatureCount;
  final int diaryCount;

  factory LogDaySummary.empty() => const LogDaySummary(
        formulaTotalMl: 0,
        breastTotalSec: 0,
        pumpedTotalMl: 0,
        babyFoodTotalMl: 0,
        diaperCount: 0,
        sleepTotal: Duration.zero,
        temperatureCount: 0,
        diaryCount: 0,
      );
}

extension TimelineEntryL10n on TimelineEntry {
  String localizedTitle(AppLocalizations l10n) {
    return switch (type) {
      TimelineEntryType.formula => l10n.entryFormula,
      TimelineEntryType.breast => l10n.entryBreast,
      TimelineEntryType.pumped => l10n.entryPumped,
      TimelineEntryType.babyFood => l10n.entryBabyFood,
      TimelineEntryType.sleep => l10n.entrySleep,
      TimelineEntryType.diaper => l10n.entryDiaper,
      TimelineEntryType.temperature => l10n.entryTemperature,
      TimelineEntryType.diary => rawTitle ?? title,
    };
  }

  String localizedSubtitle(AppLocalizations l10n) {
    switch (type) {
      case TimelineEntryType.breast:
        final sec = (rawDurationLeftSec ?? 0) + (rawDurationRightSec ?? 0);
        return Duration(seconds: sec).formatLocalized(l10n);
      case TimelineEntryType.sleep:
        final isActive = rawEndedAt == null;
        if (isActive) return l10n.entrySleeping;
        final dur = rawEndedAt!.difference(occurredAt);
        return dur.formatLocalized(l10n);
      case TimelineEntryType.diaper:
        return switch (rawDiaperType) {
          'wet' => l10n.diaperWet,
          'soiled' => l10n.diaperSoiled,
          'both' => l10n.diaperBoth,
          'dry' => l10n.diaperChange,
          _ => rawDiaperType ?? subtitle,
        };
      case TimelineEntryType.diary:
        return rawAuthorNickname ?? l10n.diaryAuthorLabel;
      default:
        return subtitle;
    }
  }
}
