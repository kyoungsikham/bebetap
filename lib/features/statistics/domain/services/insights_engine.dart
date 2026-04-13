import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import '../models/insight.dart';

class InsightsEngine {
  List<Insight> generateInsights({
    required List<FeedingEntriesTableData> recentFeedings,
    required List<SleepEntriesTableData> recentSleeps,
    required List<DiaperEntriesTableData> recentDiapers,
    required List<TemperatureEntriesTableData> recentTemperatures,
    required DateTime babyBirthDate,
  }) {
    final insights = <Insight>[];
    final now = DateTime.now();

    _checkFeedingPrediction(insights, recentFeedings, now);
    _checkNapPrediction(insights, recentSleeps, now, babyBirthDate);
    _checkIntakeDrop(insights, recentFeedings, now);
    _checkDiaperFrequency(insights, recentDiapers, now);
    _checkFever(insights, recentTemperatures);
    _checkSleepRegression(insights, recentSleeps, now);
    _checkNapNightCorrelation(insights, recentSleeps, now);

    return insights;
  }

  /// Predict next feeding based on average interval of last 5 feedings
  void _checkFeedingPrediction(
    List<Insight> insights,
    List<FeedingEntriesTableData> feedings,
    DateTime now,
  ) {
    if (feedings.length < 3) return;
    final sorted = [...feedings]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final recent = sorted.take(5).toList();

    double totalIntervalMin = 0;
    int count = 0;
    for (int i = 0; i < recent.length - 1; i++) {
      totalIntervalMin +=
          recent[i].startedAt.difference(recent[i + 1].startedAt).inMinutes;
      count++;
    }
    if (count == 0) return;

    final avgInterval = totalIntervalMin / count;
    final elapsed = now.difference(recent.first.startedAt).inMinutes;
    final remaining = (avgInterval - elapsed).round();

    if (remaining > 0 && remaining <= 60 && elapsed > avgInterval * 0.5) {
      insights.add(Insight(
        type: InsightType.prediction,
        severity: InsightSeverity.info,
        titleKey: 'insightFeedingPredictionTitle',
        bodyKey: 'insightFeedingPredictionBody',
        bodyArgs: {'minutes': remaining.toString()},
        icon: Icons.restaurant,
      ));
    }
  }

  /// Predict next nap based on age-appropriate awake window
  void _checkNapPrediction(
    List<Insight> insights,
    List<SleepEntriesTableData> sleeps,
    DateTime now,
    DateTime birthDate,
  ) {
    if (sleeps.isEmpty) return;
    final sorted = [...sleeps]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    // Find last ended sleep
    final lastEnded = sorted.where((s) => s.endedAt != null).firstOrNull;
    if (lastEnded == null) return;

    final ageMonths = (now.difference(birthDate).inDays / 30.44).floor();
    final awakeWindowMin = _awakeWindow(ageMonths);
    final awakeMin = now.difference(lastEnded.endedAt!).inMinutes;
    final remaining = (awakeWindowMin - awakeMin).round();

    if (remaining > 0 && remaining <= 30 && awakeMin > awakeWindowMin * 0.6) {
      insights.add(Insight(
        type: InsightType.prediction,
        severity: InsightSeverity.info,
        titleKey: 'insightNapPredictionTitle',
        bodyKey: 'insightNapPredictionBody',
        bodyArgs: {'minutes': remaining.toString()},
        icon: Icons.bedtime,
      ));
    }
  }

  /// Age-appropriate awake window in minutes
  double _awakeWindow(int ageMonths) {
    if (ageMonths < 2) return 60;
    if (ageMonths < 4) return 90;
    if (ageMonths < 6) return 120;
    if (ageMonths < 9) return 150;
    if (ageMonths < 12) return 180;
    if (ageMonths < 18) return 210;
    return 300;
  }

  /// Detect formula intake drop (3-day avg vs 7-day avg, >20% decrease)
  void _checkIntakeDrop(
    List<Insight> insights,
    List<FeedingEntriesTableData> feedings,
    DateTime now,
  ) {
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final recent3 = feedings
        .where((f) =>
            f.type == 'formula' && f.startedAt.isAfter(threeDaysAgo))
        .fold<int>(0, (sum, r) => sum + (r.amountMl ?? 0));
    final recent7 = feedings
        .where((f) =>
            f.type == 'formula' && f.startedAt.isAfter(sevenDaysAgo))
        .fold<int>(0, (sum, r) => sum + (r.amountMl ?? 0));

    if (recent7 == 0) return;

    final avg3 = recent3 / 3.0;
    final avg7 = recent7 / 7.0;
    if (avg7 > 0 && avg3 < avg7 * 0.8) {
      final dropPercent = ((1 - avg3 / avg7) * 100).round();
      insights.add(Insight(
        type: InsightType.anomaly,
        severity: InsightSeverity.warning,
        titleKey: 'insightIntakeDropTitle',
        bodyKey: 'insightIntakeDropBody',
        bodyArgs: {'percent': dropPercent.toString()},
        icon: Icons.trending_down,
      ));
    }
  }

  /// Low wet diaper frequency (<3 in 24h)
  void _checkDiaperFrequency(
    List<Insight> insights,
    List<DiaperEntriesTableData> diapers,
    DateTime now,
  ) {
    final oneDayAgo = now.subtract(const Duration(hours: 24));
    final wetCount = diapers
        .where((d) =>
            (d.type == 'wet' || d.type == 'both') &&
            d.occurredAt.isAfter(oneDayAgo))
        .length;

    if (wetCount < 3 && diapers.isNotEmpty) {
      insights.add(Insight(
        type: InsightType.anomaly,
        severity: InsightSeverity.alert,
        titleKey: 'insightLowWetDiapersTitle',
        bodyKey: 'insightLowWetDiapersBody',
        bodyArgs: {'count': wetCount.toString()},
        icon: Icons.warning_amber,
      ));
    }
  }

  /// Fever detection
  void _checkFever(
    List<Insight> insights,
    List<TemperatureEntriesTableData> temperatures,
  ) {
    if (temperatures.isEmpty) return;
    final sorted = [...temperatures]
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    final latest = sorted.first;

    if (latest.celsius >= 37.5) {
      insights.add(Insight(
        type: InsightType.anomaly,
        severity: latest.celsius >= 38.5
            ? InsightSeverity.alert
            : InsightSeverity.warning,
        titleKey: 'insightFeverTitle',
        bodyKey: 'insightFeverBody',
        bodyArgs: {'temp': latest.celsius.toStringAsFixed(1)},
        icon: Icons.thermostat,
      ));
    }
  }

  /// Sleep regression detection (weekly total dropped >15%)
  void _checkSleepRegression(
    List<Insight> insights,
    List<SleepEntriesTableData> sleeps,
    DateTime now,
  ) {
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    int thisWeekSec = 0;
    int lastWeekSec = 0;
    for (final s in sleeps) {
      final end = s.endedAt ?? now;
      final sec = end.difference(s.startedAt).inSeconds;
      if (s.startedAt.isAfter(oneWeekAgo)) {
        thisWeekSec += sec;
      } else if (s.startedAt.isAfter(twoWeeksAgo)) {
        lastWeekSec += sec;
      }
    }

    if (lastWeekSec > 0) {
      final dropPercent = ((lastWeekSec - thisWeekSec) / lastWeekSec * 100);
      if (dropPercent > 15) {
        insights.add(Insight(
          type: InsightType.anomaly,
          severity: InsightSeverity.warning,
          titleKey: 'insightSleepRegressionTitle',
          bodyKey: 'insightSleepRegressionBody',
          bodyArgs: {'percent': dropPercent.round().toString()},
          icon: Icons.nightlight,
        ));
      }
    }
  }

  /// Nap-night correlation: less nap → more night wakings
  void _checkNapNightCorrelation(
    List<Insight> insights,
    List<SleepEntriesTableData> sleeps,
    DateTime now,
  ) {
    if (sleeps.length < 5) return;

    // Group sleeps by day, classify nap vs night
    final dayMap = <String, ({int napMin, int nightWakings})>{};
    for (final s in sleeps) {
      final key =
          '${s.startedAt.year}-${s.startedAt.month}-${s.startedAt.day}';
      final end = s.endedAt ?? now;
      final min = end.difference(s.startedAt).inMinutes;
      final hour = s.startedAt.hour;
      final isNight = hour >= 20 || hour < 6;

      final current = dayMap[key] ?? (napMin: 0, nightWakings: 0);
      if (isNight) {
        dayMap[key] = (napMin: current.napMin, nightWakings: current.nightWakings + 1);
      } else {
        dayMap[key] = (napMin: current.napMin + min, nightWakings: current.nightWakings);
      }
    }

    if (dayMap.length < 3) return;

    // Simple check: days with below-average nap have above-average night wakings
    final entries = dayMap.values.toList();
    final avgNap = entries.fold<int>(0, (s, e) => s + e.napMin) / entries.length;
    final avgWakings =
        entries.fold<int>(0, (s, e) => s + e.nightWakings) / entries.length;

    final lowNapDays = entries.where((e) => e.napMin < avgNap * 0.7).toList();
    if (lowNapDays.isEmpty) return;

    final lowNapAvgWakings =
        lowNapDays.fold<int>(0, (s, e) => s + e.nightWakings) / lowNapDays.length;

    if (lowNapAvgWakings > avgWakings * 1.3 && lowNapDays.length >= 2) {
      insights.add(const Insight(
        type: InsightType.correlation,
        severity: InsightSeverity.info,
        titleKey: 'insightNapNightCorrelationTitle',
        bodyKey: 'insightNapNightCorrelationBody',
        icon: Icons.insights,
      ));
    }
  }
}
