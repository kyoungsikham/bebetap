import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/models/tracking_category.dart';
import '../../../../shared/providers/icon_settings_provider.dart';
import '../../domain/models/timeline_entry.dart';
import '../providers/log_provider.dart';

class LogStatsStrip extends ConsumerWidget {
  const LogStatsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(logDaySummaryProvider);
    final filter = ref.watch(selectedTimelineFilterProvider);
    final visibleTypes = ref.watch(visibleCategoriesProvider);

    // If current filter is hidden, reset to first visible type
    if (visibleTypes.isNotEmpty && !visibleTypes.contains(filter)) {
      Future.microtask(() => ref
          .read(selectedTimelineFilterProvider.notifier)
          .setFilter(visibleTypes.first));
    }

    return summaryAsync.when(
      loading: () => _StripSkeleton(count: visibleTypes.length),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) {
        final breastDur = Duration(seconds: summary.breastTotalSec);

        String valueFor(TimelineEntryType type) {
          switch (type) {
            case TimelineEntryType.formula:
              return '${summary.formulaTotalMl}ml';
            case TimelineEntryType.breast:
              return breastDur == Duration.zero ? '0분' : breastDur.formatKorean();
            case TimelineEntryType.pumped:
              return '${summary.pumpedTotalMl}ml';
            case TimelineEntryType.babyFood:
              return '${summary.babyFoodTotalMl}ml';
            case TimelineEntryType.diaper:
              return '${summary.diaperCount}회';
            case TimelineEntryType.sleep:
              return summary.sleepTotal == Duration.zero
                  ? '0분'
                  : summary.sleepTotal.formatKorean();
            case TimelineEntryType.temperature:
              return '${summary.temperatureCount}회';
            case TimelineEntryType.diary:
              return '${summary.diaryCount}편';
          }
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              for (int i = 0; i < visibleTypes.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Builder(builder: (context) {
                  final type = visibleTypes[i];
                  final info = TrackingCategoryInfo.all[type]!;
                  return _StatChip(
                    type: type,
                    isSelected: filter == type,
                    onTap: () => ref
                        .read(selectedTimelineFilterProvider.notifier)
                        .setFilter(type),
                    icon: info.icon,
                    color: info.color,
                    bgColor: info.bgColor,
                    value: valueFor(type),
                    label: info.label,
                  );
                }),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.type,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  final TimelineEntryType type;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.18) : bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.2),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: isSelected ? 0.25 : 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.onSurface,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? color : AppColors.onSurfaceMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StripSkeleton extends StatelessWidget {
  const _StripSkeleton({this.count = 8});

  final int count;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: List.generate(
          count,
          (i) => Padding(
            padding: EdgeInsets.only(right: i < count - 1 ? 10 : 0),
            child: Container(
              width: 80,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
