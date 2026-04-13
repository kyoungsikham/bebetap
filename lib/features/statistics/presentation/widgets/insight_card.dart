import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/models/insight.dart';

/// Resolve [Insight.bodyKey] + [Insight.bodyArgs] into a localized string.
String resolveInsightBody(AppLocalizations l10n, Insight insight) {
  final a = insight.bodyArgs;
  return switch (insight.bodyKey) {
    'insightFeedingPredictionBody' =>
      l10n.insightFeedingPredictionBody(a['minutes'] ?? ''),
    'insightNapPredictionBody' =>
      l10n.insightNapPredictionBody(a['minutes'] ?? ''),
    'insightIntakeDropBody' =>
      l10n.insightIntakeDropBody(a['percent'] ?? ''),
    'insightLowWetDiapersBody' =>
      l10n.insightLowWetDiapersBody(a['count'] ?? ''),
    'insightFeverBody' =>
      l10n.insightFeverBody(a['temp'] ?? ''),
    'insightSleepRegressionBody' =>
      l10n.insightSleepRegressionBody(a['percent'] ?? ''),
    'insightNapNightCorrelationBody' =>
      l10n.insightNapNightCorrelationBody,
    _ => insight.bodyKey,
  };
}

class InsightCard extends StatelessWidget {
  const InsightCard({super.key, required this.insight, required this.resolvedBody});

  final Insight insight;
  final String resolvedBody;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: insight.color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: insight.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: insight.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(insight.icon, color: insight.color, size: 15),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              resolvedBody,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
