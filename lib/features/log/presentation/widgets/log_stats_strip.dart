import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../domain/models/timeline_entry.dart';
import '../providers/log_provider.dart';

class LogStatsStrip extends ConsumerWidget {
  const LogStatsStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(logDaySummaryProvider);
    final filter = ref.watch(selectedTimelineFilterProvider);

    return summaryAsync.when(
      loading: () => const _StripSkeleton(),
      error: (_, _) => const SizedBox.shrink(),
      data: (summary) {
        final breastDur = Duration(seconds: summary.breastTotalSec);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Row(
            children: [
              _StatChip(
                type: TimelineEntryType.formula,
                isSelected: filter == TimelineEntryType.formula,
                onTap: () => ref
                    .read(selectedTimelineFilterProvider.notifier)
                    .setFilter(TimelineEntryType.formula),
                icon: Icons.local_drink,
                color: AppColors.primary,
                bgColor: const Color(0xFFEEF2FF),
                value: '${summary.formulaTotalMl}ml',
                label: '분유',
              ),
              const SizedBox(width: 10),
              _StatChip(
                type: TimelineEntryType.breast,
                isSelected: filter == TimelineEntryType.breast,
                onTap: () => ref
                    .read(selectedTimelineFilterProvider.notifier)
                    .setFilter(TimelineEntryType.breast),
                icon: Icons.favorite_outline,
                color: const Color(0xFFE91E8C),
                bgColor: const Color(0xFFFCE4EC),
                value: breastDur == Duration.zero
                    ? '0분'
                    : breastDur.formatKorean(),
                label: '모유',
              ),
              const SizedBox(width: 10),
              _StatChip(
                type: TimelineEntryType.babyFood,
                isSelected: filter == TimelineEntryType.babyFood,
                onTap: () => ref
                    .read(selectedTimelineFilterProvider.notifier)
                    .setFilter(TimelineEntryType.babyFood),
                icon: Icons.restaurant,
                color: const Color(0xFFFF9800),
                bgColor: const Color(0xFFFFF3E0),
                value: '${summary.babyFoodTotalMl}ml',
                label: '이유식',
              ),
              const SizedBox(width: 10),
              _StatChip(
                type: TimelineEntryType.diaper,
                isSelected: filter == TimelineEntryType.diaper,
                onTap: () => ref
                    .read(selectedTimelineFilterProvider.notifier)
                    .setFilter(TimelineEntryType.diaper),
                icon: Icons.baby_changing_station,
                color: const Color(0xFF52B788),
                bgColor: const Color(0xFFE8F5E9),
                value: '${summary.diaperCount}회',
                label: '기저귀',
              ),
              const SizedBox(width: 10),
              _StatChip(
                type: TimelineEntryType.sleep,
                isSelected: filter == TimelineEntryType.sleep,
                onTap: () => ref
                    .read(selectedTimelineFilterProvider.notifier)
                    .setFilter(TimelineEntryType.sleep),
                icon: Icons.bedtime_outlined,
                color: const Color(0xFF7B68EE),
                bgColor: const Color(0xFFEDE7F6),
                value: summary.sleepTotal == Duration.zero
                    ? '0분'
                    : summary.sleepTotal.formatKorean(),
                label: '수면',
              ),
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
  const _StripSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: List.generate(
          5,
          (i) => Padding(
            padding: EdgeInsets.only(right: i < 4 ? 10 : 0),
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
