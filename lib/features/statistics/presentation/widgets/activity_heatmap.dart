import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../domain/models/activity_heatmap.dart';

class ActivityHeatmapWidget extends StatelessWidget {
  const ActivityHeatmapWidget({super.key, required this.data});

  final HeatmapData data;

  static const _sleepColorLight = Color(0xFF607D8B);
  static const _sleepColorDark = Color(0xFF607D8B);
  static const _feedingColor = Color(0xFF4A90E2);
  static const _diaperColor = Color(0xFF00BFA5);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final sleepColor = Theme.of(context).brightness == Brightness.dark
        ? _sleepColorDark
        : _sleepColorLight;

    // Find max values for normalization
    double maxSleep = 0;
    double maxFeeding = 0;
    double maxDiaper = 0;
    for (final h in data.hours) {
      if (h.sleepMinutes > maxSleep) maxSleep = h.sleepMinutes;
      if (h.feedingCount > maxFeeding) maxFeeding = h.feedingCount;
      if (h.diaperCount > maxDiaper) maxDiaper = h.diaperCount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hour labels
        Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [0, 3, 6, 9, 12, 15, 18, 21].map((h) {
              return Text(
                h.toString().padLeft(2, '0'),
                style: AppTypography.labelSmall.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                  fontSize: 9,
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        // Rows
        _HeatmapRow(
          label: l10n.sleepSection,
          color: sleepColor,
          values: data.hours.map((h) => maxSleep > 0 ? h.sleepMinutes / maxSleep : 0.0).toList(),
        ),
        const SizedBox(height: 3),
        _HeatmapRow(
          label: l10n.feedingSection,
          color: _feedingColor,
          values: data.hours.map((h) => maxFeeding > 0 ? h.feedingCount / maxFeeding : 0.0).toList(),
        ),
        const SizedBox(height: 3),
        _HeatmapRow(
          label: l10n.diaperSection,
          color: _diaperColor,
          values: data.hours.map((h) => maxDiaper > 0 ? h.diaperCount / maxDiaper : 0.0).toList(),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Scale legend
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              l10n.heatmapLow,
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 9,
              ),
            ),
            const SizedBox(width: 4),
            ...List.generate(5, (i) {
              final alpha = 0.1 + (i * 0.225);
              return Container(
                width: 12,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: alpha),
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
            const SizedBox(width: 4),
            Text(
              l10n.heatmapHigh,
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 9,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeatmapRow extends StatelessWidget {
  const _HeatmapRow({
    required this.label,
    required this.color,
    required this.values,
  });

  final String label;
  final Color color;
  final List<double> values; // 24 values, 0.0-1.0

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              fontSize: 10,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: SizedBox(
            height: 20,
            child: Row(
              children: values.map((v) {
                final alpha = v > 0 ? 0.1 + (v * 0.9) : 0.05;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 0.5),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: alpha),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
