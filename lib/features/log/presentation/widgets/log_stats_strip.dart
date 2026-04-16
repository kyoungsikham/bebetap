import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../shared/extensions/datetime_ext.dart';
import '../../../../shared/extensions/l10n_ext.dart';
import '../../../../shared/models/tracking_category.dart';
import '../../../../shared/models/volume_unit.dart';
import '../../../../shared/providers/icon_settings_provider.dart';
import '../../../../shared/providers/volume_unit_provider.dart';
import '../../domain/models/timeline_entry.dart';
import '../providers/log_provider.dart';

class LogStatsStrip extends ConsumerStatefulWidget {
  const LogStatsStrip({
    super.key,
    required this.onTapCategory,
  });

  /// 아이콘 탭 시 해당 카테고리의 기록 추가 바텀시트를 열도록 호출
  final void Function(TimelineEntryType type) onTapCategory;

  @override
  ConsumerState<LogStatsStrip> createState() => _LogStatsStripState();
}

class _LogStatsStripState extends ConsumerState<LogStatsStrip> {
  final ScrollController _scrollController = ScrollController();
  LogDaySummary? _lastSummary;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(logDaySummaryProvider);
    final visibleTypes = ref.watch(visibleCategoriesProvider);
    final unit = ref.watch(volumeUnitProvider).valueOrNull ?? VolumeUnit.ml;

    // Keep last known summary to avoid scroll reset during reload
    if (summaryAsync.valueOrNull != null) {
      _lastSummary = summaryAsync.valueOrNull;
    }
    final summary = _lastSummary;

    if (summary == null) {
      return _StripSkeleton(count: visibleTypes.length);
    }

    final l10n = context.l10n;
    final breastDur = Duration(seconds: summary.breastTotalSec);

    String valueFor(TimelineEntryType type) {
      switch (type) {
        case TimelineEntryType.formula:
          return unit.formatAmount(summary.formulaTotalMl);
        case TimelineEntryType.breast:
          return breastDur.formatLocalized(l10n);
        case TimelineEntryType.pumped:
          return unit.formatAmount(summary.pumpedTotalMl);
        case TimelineEntryType.babyFood:
          return unit.formatAmount(summary.babyFoodTotalMl);
        case TimelineEntryType.diaper:
          return l10n.timesCount(summary.diaperCount);
        case TimelineEntryType.sleep:
          return summary.sleepTotal.formatLocalized(l10n);
        case TimelineEntryType.temperature:
          return l10n.timesCount(summary.temperatureCount);
        case TimelineEntryType.diary:
          return l10n.diaryCountUnit(summary.diaryCount);
      }
    }

    return SingleChildScrollView(
      controller: _scrollController,
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
                onTap: () => widget.onTapCategory(type),
                icon: info.icon,
                color: info.color,
                bgColor: info.bgColor,
                value: valueFor(type),
                label: info.localizedLabel(context.l10n),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.type,
    required this.onTap,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.value,
    required this.label,
  });

  final TimelineEntryType type;
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
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.labelLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
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
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.55),
                fontSize: 10,
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
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
