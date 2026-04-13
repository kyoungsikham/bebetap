import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/l10n_ext.dart';

class SleepVsRecommended extends StatelessWidget {
  const SleepVsRecommended({
    super.key,
    required this.actualHours,
    required this.recommendedMin,
    required this.recommendedMax,
  });

  final double actualHours;
  final double recommendedMin;
  final double recommendedMax;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final maxHours = (recommendedMax + 4).clamp(0, 24).toDouble();

    // Determine status
    final Color statusColor;
    final String statusText;
    if (actualHours < recommendedMin) {
      statusColor = AppColors.warning;
      statusText = l10n.belowRecommended;
    } else if (actualHours > recommendedMax) {
      statusColor = AppColors.warning;
      statusText = l10n.aboveRecommended;
    } else {
      statusColor = AppColors.success;
      statusText = l10n.withinRecommended;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              l10n.avgDailySleep,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusText,
                style: AppTypography.labelSmall.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 24,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final recMinFrac = recommendedMin / maxHours;
              final recMaxFrac = recommendedMax / maxHours;
              final actualFrac = (actualHours / maxHours).clamp(0.0, 1.0);

              return Stack(
                children: [
                  // Background
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // Recommended range
                  Positioned(
                    left: width * recMinFrac,
                    width: width * (recMaxFrac - recMinFrac),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                  // Actual value marker
                  Positioned(
                    left: (width * actualFrac - 2).clamp(0, width - 4),
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${actualHours.toStringAsFixed(1)}h',
              style: AppTypography.labelSmall.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${l10n.recommended}: ${recommendedMin.toStringAsFixed(0)}-${recommendedMax.toStringAsFixed(0)}h',
              style: AppTypography.labelSmall.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
